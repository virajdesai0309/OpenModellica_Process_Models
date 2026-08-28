"""
fix_model_to_record.py

Patches a known bug in OMChemSim v1.0 (FOSSEE, IIT Bombay):

    Simulator.Files.ChemsepDatabase.GeneralProperties, and every one of its
    432 compound subclasses (Water.mo, Ethanol.mo, etc.), are declared with
    the `model` keyword even though they contain nothing but `parameter`
    declarations -- i.e. they are pure data records, not models.

    Modelica reserves per-array-element binding equations (e.g.
    `extends Streams.MaterialStream(Nc = 2, C = {eth, wat})`) for classes
    with `record` specialization only. Because GeneralProperties uses
    `model`, OpenModelica raises:

        Component 'C' may not have a binding equation due to
        class specialization 'model'.

    the moment you try to instantiate a MaterialStream with named compounds.

This script rewrites the class-declaration keyword from `model` to `record`
in GeneralProperties.mo and every compound file under ChemsepDatabase/.
It does NOT touch anything else in the file (property values, comments,
`end <Name>;` lines are untouched, since `end` statements don't repeat the
specialization keyword in Modelica).

Safety checks performed automatically:
  - Confirms every target file matches the expected `model <Name>` pattern
    before editing (skips + warns instead of guessing on anything unusual).
  - Confirms no target file contains an `equation` or `algorithm` section
    (which would make it unsafe to convert to `record`) before editing.

Usage:
    python fix_model_to_record.py /path/to/Simulator
"""

import argparse
import glob
import os
import re
import sys


def patch_file(path: str, class_name_hint: str) -> str:
    """Returns 'patched', 'skipped-no-match', or 'skipped-has-equations'."""
    with open(path, encoding="utf-8", errors="replace") as fh:
        text = fh.read()

    if re.search(r"^\s*(equation|algorithm)\b", text, re.MULTILINE):
        return "skipped-has-equations"

    new_text, n = re.subn(
        r"^(\s*)model(\s+\w+)", r"\1record\2", text, count=1, flags=re.MULTILINE
    )
    if n == 0:
        return "skipped-no-match"

    with open(path, "w", encoding="utf-8") as fh:
        fh.write(new_text)
    return "patched"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "simulator_root", help="Path to the Simulator/ folder (containing Files/ChemsepDatabase)"
    )
    args = parser.parse_args()

    db_dir = os.path.join(args.simulator_root, "Files", "ChemsepDatabase")
    if not os.path.isdir(db_dir):
        sys.exit(f"Could not find {db_dir} -- check the path you passed in.")

    gp_path = os.path.join(db_dir, "GeneralProperties.mo")
    targets = [gp_path] + [
        f
        for f in glob.glob(os.path.join(db_dir, "*.mo"))
        if os.path.basename(f) not in ("GeneralProperties.mo", "package.mo")
    ]

    results = {"patched": 0, "skipped-no-match": 0, "skipped-has-equations": 0}
    for f in targets:
        outcome = patch_file(f, os.path.splitext(os.path.basename(f))[0])
        results[outcome] += 1
        if outcome != "patched":
            print(f"  [{outcome}] {f}")

    print(f"\nDone. Patched {results['patched']} of {len(targets)} files.")
    if results["skipped-no-match"] or results["skipped-has-equations"]:
        print(
            "Some files were skipped -- review the warnings above before "
            "trusting the database is fully consistent."
        )


if __name__ == "__main__":
    main()
