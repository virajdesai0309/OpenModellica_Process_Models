# OMChemSim (patched)

This is a modified copy of OMChemSim v1.0, originally developed by
FOSSEE, IIT Bombay: https://github.com/FOSSEE/OMChemSim

Licensed under the 3-Clause BSD License (see LICENSE).

## Modifications from upstream v1.0
- Fixed broken `import Simulator.Files.Thermodynamic_Functions.*;`
  statements (typo: underscore + wrong casing) in 5 files:
  RaoultsLaw.mo, NRTL.mo, GraysonStreed.mo, PoyntingCF.mo, HeatExchanger.mo.
  Corrected to `Simulator.Files.ThermodynamicFunctions.*` or removed
  where the import was unused.

- Fixed `model`/`record` specialization mismatch in `GeneralProperties.mo`
  and all 432 compound files under `Files/ChemsepDatabase/`. These were
  declared with the `model` keyword despite containing only `parameter`
  declarations, which OpenModelica rejects when binding array elements
  (e.g. `C = {eth, wat}`) — a `record` specialization is required for
  that. Fixed via `fix_model_to_record.py`, included in this repo.

- Marked `GuessModels.GuessInput` and `GuessModels.InitialGuess` as
  `partial model`. Both reference `Nc` and `C` without declaring them,
  relying on the extending class (MaterialStream, and 23 other unit
  operations across the library) to supply them — a standard Modelica
  mixin pattern, but one that requires the base class to be `partial`.
  Without it, strict/modern OpenModelica versions reject the unresolved
  reference with "Variable Nc not found in scope". Affects nearly every
  unit operation in the library (Heater, Cooler, Mixer, Flash, Valve,
  DistillationColumn, etc.), not just MaterialStream.

- Moved `Nc` (component count) and `C` (component property array) from being
  redundantly declared in 19 separate files (MaterialStream + 18 unit
  operations) into their proper common ancestor, `GuessModels.GuessInput`.
  `InitialGuess.mo` referenced `Nc`/`C` as if inherited, but neither was ever
  declared anywhere in its own ancestor chain -- Modelica name resolution
  only searches upward through ancestors, never into classes that later
  extend it. This almost certainly only worked under an older, more
  permissive OpenModelica frontend. Symptom: "Variable Nc not found in
  scope InitialGuess", persisting even after marking InitialGuess partial.