#!/usr/bin/env python3
"""Compile-and-run every executable example in the vendored OMChemSim library.

The point of this script is to make "does OMChemSim still work on my
OpenModelica?" a single command instead of a manual click-through in OMEdit.
Run it after upgrading OpenModelica, or after touching anything under
vendor/OMChemSim-v1.0/, and diff the summary against the previous run.

    python tools/run_regression.py                 # all examples
    python tools/run_regression.py --filter Flash  # just the ones matching
    python tools/run_regression.py --check-only    # translate, don't simulate

Exit code is non-zero if any model regressed to FAIL.
"""

import argparse
import csv
import glob
import json
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIBRARY = os.path.join(REPO, "vendor", "OMChemSim-v1.0", "Simulator", "package.mo")

# The vendored library is ported to MSL 4.x. Note that omc treats this as a
# minimum rather than an exact pin: asking for "4.0.0" on a machine that also
# has 4.1.0 installed loads 4.1.0. Asking across a major version is honoured
# exactly, so "3.2.3" really would load 3.2.3 -- and would then fail, because
# Modelica.Math.Polynomials does not exist there. See ATTRIBUTION.md section 6.
MSL_VERSION = "4.1.0"

# Executable examples, i.e. those that extend Modelica.Icons.Example and carry a
# complete set of specifications. The other classes in Examples/ are partial
# composition helpers (typically named MS) that cannot be simulated on their own.
EXAMPLES = [
    "Simulator.Examples.MaterialStream.TPflash",
    "Simulator.Examples.MaterialStream.TVFflash",
    "Simulator.Examples.MaterialStream.PVFflash",
    "Simulator.Examples.MaterialStream.PHflash",
    "Simulator.Examples.MaterialStream.PSflash",
    "Simulator.Examples.MaterialStream.BelBubl",
    "Simulator.Examples.MaterialStream.UNIQUAC",
    "Simulator.Examples.MaterialStream.NRTL",
    "Simulator.Examples.MaterialStream.GraysonStreed",
    "Simulator.Examples.CompositeMS.MatStreamSimulation",
    "Simulator.Examples.Heater.HeaterSimulation",
    "Simulator.Examples.Cooler.CoolerSimulation",
    "Simulator.Examples.HeatExchanger.HXSimulation",
    "Simulator.Examples.HeatExchanger.ShellnTubeHXSimulation",
    "Simulator.Examples.Valve.ValveSimulation",
    "Simulator.Examples.Mixer.MixerSimulation",
    "Simulator.Examples.Splitter.SplitterSimulation",
    "Simulator.Examples.CompoundSeparator.CompSepSimulation",
    "Simulator.Examples.Flash.FlashSimulation",
    "Simulator.Examples.Pump.PumpSimulation",
    "Simulator.Examples.Compressor.CompressorSimulation",
    "Simulator.Examples.Expander.ExpanderSimulation",
    "Simulator.Examples.ShortcutColumn.ShortcutSimulation",
    "Simulator.Examples.Distillation.DistillationSimulation_Ex1",
    "Simulator.Examples.Distillation.DistillationSimulation_Ex2",
    "Simulator.Examples.Distillation.DistillationSimulation_Ex3",
    "Simulator.Examples.Distillation.DistillationSimulation_Ex4",
    "Simulator.Examples.Distillation.DistillationSimulation_Ex5",
    "Simulator.Examples.Absorption.AbsorptionSimulation",
    "Simulator.Examples.ConversionReactor.ConvReactSimulation",
    "Simulator.Examples.EquilibriumReactor.EqReactorSimulation_Ex1",
    "Simulator.Examples.EquilibriumReactor.EqReactorSimulation_Ex2",
    "Simulator.Examples.CSTR.CSTRSimulation_Ex1",
    "Simulator.Examples.CSTR.CSTRSimulation_Ex2",
    "Simulator.Examples.PFR.PFRSimulation",
]

# Extra models to cover that live outside the vendored library, e.g. the
# user's own models. Each entry is (extra .mo file to load, class name).
LOCAL_MODELS = [
    (os.path.join(REPO, "01_Material_Stream", "MyModels.mo"), "MyModels.MyFirstStream"),
    (os.path.join(REPO, "03_Multi_Stream", "MultiStream.mo"), "MultiStream.TwoStreams"),
    (os.path.join(REPO, "03_Multi_Stream", "MultiStream.mo"), "MultiStream.StreamSweep"),
]


def find_omc():
    """Locate omc.exe, preferring PATH, then the usual Windows install roots."""
    from shutil import which

    found = which("omc") or which("omc.exe")
    if found:
        return found
    candidates = sorted(
        glob.glob("C:/OpenModelica*/bin/omc.exe")
        + glob.glob("C:/Program Files/OpenModelica*/bin/omc.exe")
        + glob.glob("/usr/bin/omc")
        + glob.glob("/opt/openmodelica/bin/omc"),
        reverse=True,  # newest install first
    )
    if candidates:
        return candidates[0]
    sys.exit("omc not found. Put it on PATH or install OpenModelica.")


def run_one(omc, workdir, model, extra_file, check_only):
    """Translate (and optionally simulate) one model; return a result dict."""
    script = os.path.join(workdir, "run.mos")
    loads = ['loadFile("%s"); getErrorString();' % LIBRARY.replace("\\", "/")]
    if extra_file:
        loads.append('loadFile("%s"); getErrorString();' % extra_file.replace("\\", "/"))

    if check_only:
        action = "checkModel(%s);" % model
    else:
        # A steady-state flowsheet has no dynamics, so one interval is enough;
        # csv keeps the result readable without a mat reader.
        action = (
            'simulate(%s, stopTime=1, numberOfIntervals=1, outputFormat="csv");' % model
        )

    with open(script, "w") as fh:
        fh.write('loadModel(Modelica, {"%s"}); getErrorString();\n' % MSL_VERSION)
        fh.write("\n".join(loads) + "\n")
        fh.write(action + "\n")
        fh.write("getErrorString();\n")

    proc = subprocess.run(
        [omc, "run.mos"], cwd=workdir, capture_output=True, text=True, timeout=900
    )
    out = proc.stdout + proc.stderr

    if check_only:
        ok = "completed successfully" in out
        detail = "" if ok else first_error(out)
        return {"model": model, "status": "PASS" if ok else "FAIL", "detail": detail}

    # simulate() reports failure inside the messages field of its result record
    # rather than through a non-zero exit code, so parse the record.
    ok = 'resultFile = ""' not in out and "Simulation execution failed" not in out
    if ok and "finished successfully" not in out:
        ok = False
    detail = "" if ok else first_error(out)
    return {"model": model, "status": "PASS" if ok else "FAIL", "detail": detail}


def first_error(out):
    """Pull the most informative single line out of an omc transcript."""
    interesting = re.compile(
        r"(division by zero|Error|error:|singular|not solvable|over specified"
        r"|No system|failed|Failed|assertion)"
    )
    noise = re.compile(r"Warning|Notification|getErrorString|deprecated")
    for line in out.splitlines():
        line = line.strip()
        if interesting.search(line) and not noise.search(line):
            return line[:300]
    return "(see full log)"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--filter", default="", help="only run models whose name contains this")
    ap.add_argument("--check-only", action="store_true", help="translate only, do not simulate")
    ap.add_argument("--json", default="", help="also write results as JSON to this path")
    args = ap.parse_args()

    omc = find_omc()
    version = subprocess.run(
        [omc, "--version"], capture_output=True, text=True
    ).stdout.strip()
    print("omc:  %s" % omc)
    print("      %s" % version)
    print("MSL:  %s" % MSL_VERSION)
    print()

    targets = [(None, m) for m in EXAMPLES] + [(f, m) for f, m in LOCAL_MODELS]
    if args.filter:
        targets = [t for t in targets if args.filter.lower() in t[1].lower()]

    results = []
    with tempfile.TemporaryDirectory(prefix="omchemsim_reg_") as workdir:
        for extra_file, model in targets:
            short = model.replace("Simulator.Examples.", "")
            print("  %-52s " % short, end="", flush=True)
            try:
                res = run_one(omc, workdir, model, extra_file, args.check_only)
            except subprocess.TimeoutExpired:
                res = {"model": model, "status": "TIMEOUT", "detail": "exceeded 900s"}
            results.append(res)
            print(res["status"] + ("  %s" % res["detail"] if res["detail"] else ""))

    passed = sum(1 for r in results if r["status"] == "PASS")
    print()
    print("%d/%d passed" % (passed, len(results)))

    if args.json:
        with open(args.json, "w") as fh:
            json.dump({"omc": version, "msl": MSL_VERSION, "results": results}, fh, indent=2)
        print("wrote %s" % args.json)

    return 0 if passed == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())
