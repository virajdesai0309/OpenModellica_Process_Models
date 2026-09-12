#!/usr/bin/env python3
"""Run a factorial design of experiments over a Modelica model, without recompiling.

A Modelica model is compiled into a standalone executable, and that executable
accepts new values for any parameter on its command line via -override. So a
parameter study costs one compile plus one cheap run per point, instead of one
compile per point -- which is the difference between seconds and hours once the
grid has a few dozen points in it.

    # the built-in grid: hydrocarbon P x T x composition, water P x T
    python tools/run_doe.py

    # your own factors, full factorial over whatever you list
    python tools/run_doe.py --factor T_hc=300,310,320 --factor P_hc=3e5,5e5,8e5

    # a different model
    python tools/run_doe.py --model MyModels.MyFirstStream \\
        --load 01_Material_Stream/MyModels.mo --factor P=1e5,2e5

Every point that solves contributes a row to the output CSV; every point that
does not is reported and left out, with the count summarised at the end. A
process model failing to converge at some corner of the operating envelope is
ordinary -- the point of running the grid is to find out where. So is converging
on an answer that is not physical, which is checked for and treated the same way
(see VALIDITY below).
"""

import argparse
import csv
import glob
import itertools
import os
import shutil
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIBRARY = os.path.join(REPO, "vendor", "OMChemSim-v1.0", "Simulator", "package.mo")

# The vendored library is ported to MSL 4.x; it will not compile against 3.2.3.
MSL_VERSION = "4.1.0"

DEFAULT_MODEL = "MultiStream.TwoStreams"
DEFAULT_LOAD = os.path.join(REPO, "03_Multi_Stream", "MultiStream.mo")

# Full factorial unless --factor is given. 3 x 3 x 3 x 2 x 3 = 162 points, of
# which the infeasible compositions are dropped -- see feasible() below.
#
# The hydrocarbon levels sit inside the two-phase envelope and just outside its
# dew-point edge, which is where the Peng-Robinson flash in the vendored library
# is dependable. Push T_hc below the bubble point and points start dropping out;
# that is a limitation of the library, documented in 03_Multi_Stream/README.md.
DEFAULT_FACTORS = [
    ("P_hc", [4e5, 5e5, 6e5]),          # hydrocarbon pressure, Pa
    ("T_hc", [305, 315, 325]),          # hydrocarbon temperature, K
    ("z_c3", [0.4, 0.5, 0.6]),          # propane mole fraction
    ("P_w", [10e5, 40e5]),              # water pressure, Pa
    ("T_w", [500, 600, 700]),           # water temperature, K
]

# A grid point that does not converge is usually a bad start value rather than a
# state with no solution: the flash at the cold end of the grid really is almost
# all liquid, and a vapour-fraction guess of 0.5 is nowhere near it. So on a
# failure the point is retried with each of these in turn. They are start values
# only -- whichever one gets the solver home, the answer it lands on is the same.
DEFAULT_RETRIES = ("xvap_guess", [0.5, 0.02, 0.98, 0.2, 0.8])

# The mole fractions the model takes as specifications, and its own defaults for
# them. feasible() uses these to check the composition balance even when only
# one of them is being swept. Empty this for a model with a different feed.
COMPOSITION_DEFAULTS = {"z_c3": 0.5, "z_nc4": 0.3}

# Bounds an output has to satisfy for the point to count as solved. A converged
# run is not automatically a physical one: the Rachford-Rice closure the flash
# uses has roots outside 0 <= xvap <= 1, and Newton can land on one of them. The
# phase-region test does not catch it either, because the library computes
# Pbubl and Pdew from Raoult's law whatever property package is mixed in -- so
# under Peng-Robinson a point can sit inside the ideal two-phase window and
# still flash to a vapour fraction of 3.5. Treated here the way a converged-but-
# nonsense result should be treated: as a failed attempt, retried with the next
# start value. Applied only to outputs that are actually being recorded.
VALIDITY = {
    "HC.xvap": (-1e-6, 1 + 1e-6),
    "HC.xliq": (-1e-6, 1 + 1e-6),
}

# Recorded for every point that solves. Anything the model computes can go here.
DEFAULT_OUTPUTS = [
    # hydrocarbon stream, Peng-Robinson
    "HC.xvap", "HC.xliq", "HC.Pbubl", "HC.Pdew",
    "HC.K_c[1]", "HC.K_c[2]", "HC.K_c[3]",
    "HC.x_pc[2,1]", "HC.x_pc[3,1]",
    "HC.H_p[1]", "HC.MW_p[1]", "Fm_hc",
    # water stream, IF97 steam tables
    "W.h", "W.s", "W.d", "W.cp", "W.Tsat", "W.dTsup", "W.phase", "W.Fv",
]


def find_omc():
    """Locate omc, preferring PATH, then the usual install roots."""
    found = shutil.which("omc") or shutil.which("omc.exe")
    if found:
        return found
    candidates = sorted(
        glob.glob("C:/OpenModelica*/bin/omc.exe")
        + glob.glob("C:/Program Files/OpenModelica*/bin/omc.exe")
        + glob.glob("/usr/bin/omc")
        + glob.glob("/opt/openmodelica/bin/omc"),
        reverse=True,
    )
    if candidates:
        return candidates[0]
    sys.exit("omc not found. Put it on PATH or install OpenModelica.")


def runtime_env(omc):
    """PATH the generated executable needs to find the OpenModelica runtime DLLs.

    omc itself resolves them relative to its own location, but the executable it
    generates does not: run it with a bare PATH on Windows and it dies with
    "error while loading shared libraries: api-ms-win-crt-utility-l1-1-0.dll".
    Prepend OpenModelica's own bin and its bundled mingw bin.
    """
    env = dict(os.environ)
    root = os.path.dirname(os.path.dirname(os.path.abspath(omc)))
    extra = [os.path.join(root, "bin"),
             os.path.join(root, "tools", "msys", "mingw64", "bin"),
             os.path.join(root, "lib")]
    extra = [d for d in extra if os.path.isdir(d)]
    if extra:
        env["PATH"] = os.pathsep.join(extra) + os.pathsep + env.get("PATH", "")
    return env


def build(omc, workdir, model, loads):
    """Compile the model once and return the path to its executable."""
    script = os.path.join(workdir, "build.mos")
    with open(script, "w") as fh:
        fh.write('loadModel(Modelica, {"%s"}); getErrorString();\n' % MSL_VERSION)
        for path in loads:
            fh.write('loadFile("%s"); getErrorString();\n' % path.replace("\\", "/"))
        # A steady-state model has nothing to integrate; one interval is the
        # whole answer. Models with real dynamics need a longer stopTime here.
        #
        # outputFormat is fixed at build time, not by the -r=... name handed to
        # the executable: ask for csv here, or every point comes back as a
        # binary .mat file whatever it has been called.
        fh.write('buildModel(%s, stopTime = 1, numberOfIntervals = 1, '
                 'outputFormat = "csv");\n' % model)
        fh.write("getErrorString();\n")

    proc = subprocess.run([omc, "build.mos"], cwd=workdir, capture_output=True,
                          text=True, timeout=1800)
    exe = os.path.join(workdir, model + (".exe" if os.name == "nt" else ""))
    if not os.path.exists(exe):
        print(proc.stdout)
        print(proc.stderr, file=sys.stderr)
        sys.exit("build failed for %s -- see the transcript above" % model)
    return exe


def run_point(exe, workdir, env, overrides, outputs, index):
    """Run one grid point; return {output name: value} or None if it failed.

    -override is applied at run time, after the parameters have been read from
    the generated init file, so it reaches anything the compiler did not fold
    away as a constant. Guess anchors bound to a specification parameter
    (Pg = P_hc, Tg_user = T_hc) follow the override with it, which is why the
    start values stay sensible across the grid.
    """
    result = os.path.join(workdir, "point_%04d.csv" % index)
    spec = ",".join("%s=%r" % (k, v) for k, v in overrides.items())
    cmd = [exe, "-override=" + spec, "-r=" + result]
    try:
        subprocess.run(cmd, cwd=workdir, env=env, capture_output=True, text=True,
                       timeout=300)
    except subprocess.TimeoutExpired:
        return None
    if not os.path.exists(result):
        return None
    with open(result, newline="", encoding="utf-8", errors="replace") as fh:
        rows = list(csv.reader(fh))
    if len(rows) < 2:
        return None
    # Last row = end of the run. For a steady-state model every row is the same.
    record = dict(zip(rows[0], rows[-1]))
    missing = [name for name in outputs if name not in record]
    if missing:
        sys.exit("model does not report: %s\n"
                 "Check the names against the result file %s"
                 % (", ".join(missing), result))
    got = {name: record[name] for name in outputs}

    for name, (low, high) in VALIDITY.items():
        if name not in got:
            continue
        try:
            value = float(got[name])
        except ValueError:
            return None
        if not low <= value <= high:
            return None
    return got


def feasible(point):
    """Reject grid points that are not a physically meaningful specification.

    Mole fractions are the usual offender: the multi-stream models take two of
    the three as specifications and let n-pentane make up the balance, so a grid
    that sweeps them freely produces combinations whose balance is negative.
    Nothing stops the solver attempting those, and what it reports back looks
    like a convergence problem rather than a bad specification -- which is
    exactly the confusion worth avoiding in a results table.

    A mole fraction that is not being swept still counts towards the balance, so
    the model's own default fills in for it.
    """
    z = dict(COMPOSITION_DEFAULTS)
    z.update({k: v for k, v in point.items() if k in COMPOSITION_DEFAULTS})
    if any(v <= 0 for v in z.values()) or sum(z.values()) >= 1.0:
        return False
    return True


def parse_factor(text):
    """--factor NAME=v1,v2,v3 -> (NAME, [v1, v2, v3])"""
    if "=" not in text:
        sys.exit("--factor needs NAME=v1,v2,...  (got %r)" % text)
    name, values = text.split("=", 1)
    try:
        return name.strip(), [float(v) for v in values.split(",")]
    except ValueError:
        sys.exit("--factor values must be numbers (got %r)" % values)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", default=DEFAULT_MODEL, help="class name to simulate")
    ap.add_argument("--load", action="append", default=[],
                    help="extra .mo file to load; repeatable (default: the multi-stream models)")
    ap.add_argument("--no-library", action="store_true",
                    help="do not load OMChemSim (for a model that only needs the MSL)")
    ap.add_argument("--factor", action="append", default=[],
                    help="NAME=v1,v2,... ; repeatable. Replaces the built-in grid entirely.")
    ap.add_argument("--output", action="append", default=[],
                    help="result variable to record; repeatable. Replaces the built-in list.")
    ap.add_argument("--retry", default=None,
                    help="NAME=v1,v2,... start values to try in turn when a point does not "
                         "converge. Defaults to xvap_guess for the multi-stream models; "
                         "pass 'none' to disable.")
    ap.add_argument("--out", default=os.path.join(REPO, "03_Multi_Stream", "doe_results.csv"),
                    help="where to write the consolidated results")
    ap.add_argument("--keep", action="store_true",
                    help="keep the build directory and the per-point result files")
    args = ap.parse_args()

    factors = [parse_factor(f) for f in args.factor] or DEFAULT_FACTORS
    outputs = args.output or DEFAULT_OUTPUTS
    loads = list(args.load) or ([DEFAULT_LOAD] if args.model.startswith("MultiStream.") else [])
    if not args.no_library:
        loads = [LIBRARY] + loads

    if args.retry is None:
        retry_name, retry_values = (DEFAULT_RETRIES if args.model == DEFAULT_MODEL
                                    else (None, [None]))
    elif args.retry.lower() == "none":
        retry_name, retry_values = None, [None]
    else:
        retry_name, retry_values = parse_factor(args.retry)

    names = [n for n, _ in factors]
    grid = [dict(zip(names, combo)) for combo in itertools.product(*[v for _, v in factors])]
    points = [p for p in grid if feasible(p)]
    skipped = len(grid) - len(points)

    omc = find_omc()
    version = subprocess.run([omc, "--version"], capture_output=True, text=True).stdout.strip()
    print("omc:    %s" % version)
    print("model:  %s" % args.model)
    print("grid:   %s" % " x ".join("%s(%d)" % (n, len(v)) for n, v in factors))
    print("points: %d" % len(points) + ("  (%d infeasible, skipped)" % skipped if skipped else ""))
    if retry_name:
        print("retry:  %s = %s" % (retry_name, ", ".join("%g" % v for v in retry_values)))
    print()

    workdir = tempfile.mkdtemp(prefix="omdoe_")
    try:
        print("building once ... ", end="", flush=True)
        exe = build(omc, workdir, args.model, loads)
        env = runtime_env(omc)
        print("done")
        print()

        rows, failures = [], []
        for i, point in enumerate(points, 1):
            label = " ".join("%s=%g" % (k, v) for k, v in point.items())
            print("  [%3d/%3d] %-58s " % (i, len(points), label), end="", flush=True)

            got, used = None, None
            for guess in retry_values:
                attempt = dict(point)
                if retry_name is not None:
                    attempt[retry_name] = guess
                got = run_point(exe, workdir, env, attempt, outputs, i)
                if got is not None:
                    used = guess
                    break

            if got is None:
                print("no solution")
                failures.append(point)
                continue
            print("ok" if used == retry_values[0]
                  else "ok  (%s=%g)" % (retry_name, used))
            row = dict(point)
            row.update(got)
            rows.append(row)

        print()
        print("%d/%d points solved" % (len(rows), len(points)))

        if rows:
            out_dir = os.path.dirname(os.path.abspath(args.out))
            if out_dir:
                os.makedirs(out_dir, exist_ok=True)
            with open(args.out, "w", newline="") as fh:
                writer = csv.DictWriter(fh, fieldnames=names + outputs)
                writer.writeheader()
                writer.writerows(rows)
            print("wrote %s" % args.out)

        if failures:
            print()
            print("no solution at %d point(s) -- the run either did not converge, or "
                  "converged outside the physical range:" % len(failures))
            for point in failures:
                print("  " + " ".join("%s=%g" % (k, v) for k, v in point.items()))
            if retry_name:
                print("Every %s in --retry was tried. Widen that list, or check whether "
                      "the specification itself is the problem." % retry_name)
            else:
                print("Retrying is off. --retry NAME=v1,v2,... would try each of those "
                      "start values before giving up on a point.")
    finally:
        if args.keep:
            print()
            print("build directory kept at %s" % workdir)
        else:
            shutil.rmtree(workdir, ignore_errors=True)

    return 0 if rows else 1


if __name__ == "__main__":
    sys.exit(main())
