# OMChemSim (patched)

This is a modified copy of OMChemSim v1.0, originally developed by
FOSSEE, IIT Bombay: https://github.com/FOSSEE/OMChemSim

Licensed under the 3-Clause BSD License (see LICENSE).

Upstream v1.0 was written against an OpenModelica release whose frontend was
considerably more permissive than the current one. The patches below are what
it took to make the library translate and run on **OpenModelica 1.27.0** with
**MSL 4.1.0**. They fall into a small number of recurring categories, listed
first so the pattern is visible; verify with `python tools/run_regression.py`.

---

## 1. Cross-class name resolution (the big one)

OMChemSim builds a flowsheet model by mixing two independent halves into one
class — a *host* (MaterialStream, Flash, a column tray, a reactor) and a
*mixin* (a thermodynamic package, or a reaction definition):

```modelica
model MS
  extends Simulator.Streams.MaterialStream;                   // host
  extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;   // mixin
end MS;
```

Each half freely referenced variables declared in the other. Upstream relied on
both halves being flattened into a single scope before any name was resolved.
OpenModelica's new frontend resolves a name against the class's own scope and
its ancestors only — never sideways into a sibling base class, and never
downwards into a subclass. Every such reference now fails:

```
Error: Variable Nc not found in scope RaoultsLaw.
Error: Variable gmabubl_c[:] not found in scope Flash.
Error: Variable K_c[:] not found in scope ShortcutColumn.
Error: Variable BC_r[1] not found in scope EquilibriumReaction.
Error: Variable tray[1].Fliq_s[1] not found in scope AbsCol.
```

Marking the classes `partial` does **not** help; the lookup is not deferred.

**Fix:** declare each shared name in a class that is a genuine ancestor of both
halves. Two new declaration-only interface models were added:

- `Files/ThermodynamicPackages/PartialThermoInterface.mo` — the host ↔
  thermodynamic-package contract. Host side: `P`, `T`, `x_pc`, `Pbubl`, `Pdew`.
  Package side: `K_c`, `gma_c`, `Pvap_c`, `Cpres_p`, `Hres_p`, `Sres_p`,
  `gmabubl_c`, `gmadew_c`, `philiqbubl_c`, `phivapdew_c`.
  Extended by MaterialStream, Flash (both), ShortcutColumn, Cond, DistTray,
  Reb, AbsTray, and by RaoultsLaw, NRTL, UNIQUAC, UNIFAC, PengRobinson,
  GraysonStreed.

- `Files/Models/ReactionManager/PartialReactionInterface.mo` — the reactor ↔
  reaction contract: `Nr`, `BC_r`, `Coef_cr`, `Schk_r`, `Hf_c`, `Hr_r`.
  Extended by ConversionReaction, KineticReaction, EquilibriumReaction and by
  ConversionReactor.

Both are **declaration-only**. That is load-bearing: when the two halves are
mixed, the interface is reached twice, and Modelica merges duplicate inherited
*declarations* but duplicates inherited *equation sections*.

For the column models, where the ancestor referenced components declared in its
subclass, the fix is `replaceable`/`redeclare` instead:

- `AbsCol` now declares `tray` itself, with a `replaceable model TrayModel`;
  `Examples.Absorption.AbsColumn` supplies the concrete type via `redeclare`.
- `DistCol` likewise declares `condenser`, `reboiler` and `tray` via
  `replaceable model CondenserModel / TrayModel / ReboilerModel`.

### Consequence for callers — how to write a composite model

`Nc` and `C` are now inherited through two paths, so a modification attached to
only one of them is rejected (`Duplicate elements (due to inherited elements)
not identical`). Either put the modification **below** the diamond:

```modelica
partial model MS
  extends Simulator.Streams.MaterialStream;
  extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;
end MS;
...
MS S1(Nc = 2, C = {eth, wat});
```

or repeat it on **both** extends clauses:

```modelica
extends Simulator.Streams.MaterialStream(Nc = 2, C = {eth, wat});
extends Simulator.Files.ThermodynamicPackages.RaoultsLaw(Nc = 2, C = {eth, wat});
```

`Examples/MaterialStream.mo` used the rejected form throughout and was
converted to the second style.

---

## 2. Initial-guess generation rewritten (`GuessModels/InitialGuess.mo`)

Upstream declared every guess as `parameter Real x(fixed = false)` and computed
them in an `initial equation` section — turning guess generation into a
~45-equation coupled non-linear initialisation system that had to be solved
*before* the actual process model, with no reliable start values of its own and
with `1/Px`, `1/Psatt` and Real-valued `==` / `<>` branches inside it.

Because `initial equation` sections are duplicated once per extends path while
the variables they solve for are merged, inheriting `InitialGuess` through more
than one path over-determined the system. OpenModelica 1.27 reported:

```
Warning: The initial conditions are over specified. The following 90 initial
         equations are redundant, so they are removed ...
LOG_ASSERT | division by zero at time 0, (a=0.5) / (b=0), divisor Psatt[2]
```

— the compiler dropped an arbitrary subset of the duplicates, left `Psatt` at
its default 0.0, and the first division by it aborted the run.

**Fix:** every guess is now a plain parameter with a binding equation, computed
top-down. There is no initialisation system for the guesses at all, so it
cannot be singular or over-specified, and `InitialGuess` became safe to inherit
through several paths. Three new functions do the work:

- `ThermodynamicFunctions/SatT.mo` — pure-component saturation temperature,
  by bisection on the DIPPR-101 correlation, bracketed on `[0.15*Tc, Tc]`.
- `ThermodynamicFunctions/BubbleT.mo`, `DewT.mo` — mixture bubble and dew
  temperature, bracketed between the lowest and highest pure-component
  saturation temperature, which is provably valid for any component set.

Bisection is deliberate: it needs no derivative and no start value, cannot
leave its bracket, and always terminates. Consequently nothing depends on
hand-tuned start attributes any more, so the guesses are no longer silently
specialised to one chemical system.

### Guess anchors for mixtures the derivation cannot handle

The derived guess assumes every component can condense. That breaks down when a
permanent gas is present: air's vapour-pressure correlation extrapolated to
1 atm crosses at 78.6 K, so an acetone/air/water absorber derives a bubble
temperature of 90 K and a guess of about 220 K while the column runs near 330 K.
There is no reliable way to identify a non-condensable from component data alone
— the test would need the operating temperature, which is exactly what is being
guessed — so instead of a heuristic that would misfire on genuine
low-temperature VLE, `GuessInput` gained two optional anchors:

- `Tg_user` — temperature guess in K; `0` (default) derives it as before.
- `xg_user[Nc]` — composition guess; all zeros (default) assumes equimolar.

Both affect start values only and cannot change the converged solution.
`Examples/Absorption.mo` sets them, which is what makes that example converge;
without them the flash of the air-bearing product stream diverges to inf/nan.

Behaviour preserved from upstream, with three corrections:
- the phase-regime branch now switches on an `Integer`, not on Real equality;
- the composition clamp used to test `xg[i] > 1` — the variable being defined —
  where it meant `xmol[i]`; it is now `min`/`max`;
- `Pbubl` and `Pdew` had their start values swapped (`Pmin` is the dew
  pressure, `Pmax` the bubble pressure).

---

## 3. Strict-Modelica conformance fixes

Mechanical, but they blocked translation.

- **`each` on array modifications.** A scalar modifier applied to an array
  component now requires `each`. Fixed in Mixer, Splitter, CompoundSeparator,
  HeatExchanger, ShortcutColumn, DistTray, Cond, Reb, AbsTray, PengRobinson,
  EquilibriumReaction, TowUNIQUAC and both BinaryPhaseEnvelope models. Also
  fixed the inverse: `each` applied to scalar components in Mixer.
- **Array-shape mismatches in `start`.** `start = {Fg, Fg}` on a `[2, Nc]`
  component, and `start = {Fg, Fliqg, Fvapg}` on a `[3, Nc]` component, in
  CompoundSeparator and PFR.
- **Function locals must be protected.** Moved into `protected` sections in
  BIPUNIQUAC, EOSConstants, EOSConstantII, DensityRacket, PoyntingCF,
  PFR/Integral and BinaryPhaseEnvelopeUNIQUAC.
- **Assignment to a loop iterator** (`i := i;`) in `ReactionManager/BaseCalc.mo`
  — no-op else branches, removed.
- **`product()` of a scalar** in `PFR/Integral.mo`; the enclosing loop already
  accumulates the product.
- **Broken imports.** `Simulator.Files.Thermodynamic_Functions` (extra
  underscore, wrong casing) does not exist; corrected to
  `ThermodynamicFunctions` in NRTL, GraysonStreed, PoyntingCF, HeatExchanger
  and removed where unused in RaoultsLaw.
- **`model` used where `record` is required** in `GeneralProperties.mo` and all
  432 compound files under `Files/ChemsepDatabase/`, which blocked binding
  array elements (`C = {eth, wat}`). Fixed via `fix_model_to_record.py`.
- **`partial` on mixin base classes** `GuessModels.GuessInput` and
  `GuessModels.InitialGuess`, which reference `Nc`/`C` without declaring them.
- **`Nc`/`C` moved** out of 19 separate redundant declarations into their
  common ancestor `GuessModels.GuessInput`.
- **`enConn` has no `Nc`** — removed the `each Nc = Nc` modification from
  `DistCol`'s energy connector array.

---

## 4. Genuine upstream bugs surfaced by the stricter frontend

These were wrong before; the old frontend just did not object.

- `HeatExchanger.mo`: `xhin_pc`, `xhout_pc`, `xcin_pc`, `xcout_pc` were
  declared `[2, Nc]` but the enthalpy and Cp routines loop `for i in 2:3` over
  them. Widened to `[3, Nc]` (mixture / liquid / vapour, as everywhere else)
  and the third row wired to the connector, which already carried it.
- `HeatExchanger.mo`: `extends GuessModels.InitialGuess` sat inside the
  `protected` section, which made the inherited `Nc` and `C` protected and
  therefore unmodifiable at instantiation. Moved above `protected`.
- `ShortcutColumn.mo`: referenced `K[:]` where the K-value array is `K_c[:]`.
- `HV.mo` (heat of vaporisation) guarded the upper end of the DIPPR-106
  correlation (`T >= Tc` returns 0) but not the lower end. A solver iterate that
  overshot into negative temperature gave `Tr << 0`, so the base `(1 - Tr)` rose
  far above 1 while the cubic-in-`Tr` exponent reached the thousands —
  `Invalid root: (18.8383)^(27009.3)`, overflowing to infinity and aborting the
  run. `Tr` is now clamped at 0, which is continuous there and lets the solver
  iterate back into range instead of the simulation terminating.
- `AbsTray.mo`: `x_pc` declared with `each max = 0`, pinning every mole
  fraction to zero. Corrected to `each max = 1`.
- `Cond.mo`: `P` carried `unit = "K"` and `T` carried `unit = "Pa"`; resolved
  by consolidating both into `PartialThermoInterface`.
- `Examples/Absorption.mo`: stream `S2` was instantiated without `Nc`/`C`,
  which the new frontend reports as an internal error on an invalid range.
- `DistTray.mo`, `Cond.mo`, `Reb.mo`: every feed connector came as a pair of
  conditional components, `In if Bin` and `In_Dmy if not Bin`, which were then
  referenced in ordinary equations. Modelica permits a conditional component
  only inside a `connect` statement, so this is rejected with `'B1.tray[1].In.P'
  refers to a component with a false condition`. `In` is now unconditional and
  `In_Dmy` is gone; the `not Bin` branch zeroes the feed quantities and the
  unconnected `In` explicitly, which is what the all-zero `In_Dmy` did
  implicitly. The two branches have different equation counts, which is legal
  because `Bin` is a parameter.
- `CSTR.mo`: mixes in a thermodynamic package but carries its flash on
  `xout_pc`, leaving the interface's `x_pc` with no equations at all
  (`Too few equations, under-determined system`, short by exactly 3*Nc). Added
  `x_pc = xout_pc` — the package is evaluated at the reactor outlet.
- `EquilibriumReaction.mo`: `A`, `B` and `Kg` had neither value nor start value
  but are `fixed = true`, so the backend refused to evaluate them even when
  `Rmode` never reads them. Defaulted to zeros.
- `Examples/MaterialStream.mo` (`TVFflash`): `Simulator.Files.ChemsepDatabase
  data;` declared the package as a *component* and then used `data.Methanol` as
  a type. Replaced with the `import data = ...` the sibling models use.

### Peng-Robinson

No upstream example exercises `ThermodynamicPackages.PengRobinson` on a material
stream, so none of the three below had ever been hit. All three surface the
moment you write `extends MaterialStream; extends PengRobinson;`.

- Every other package writes the interface's activity coefficient `gma_c`;
  Peng-Robinson declared a *local* `Real gma[Nc]` and set that instead, leaving
  `gma_c` with no equation at all — `Too few equations, under-determined system.
  The model has 239 equation(s) and 242 variable(s)`, short by exactly `Nc`.
  The local array is gone and the equation now writes `gma_c`.
- The vapour-side guard tested `Zvv + 2.4142135 * Avap <= 0` while the branch it
  guards computes `Zvv + 2.4142135 * Bvap`. With the wrong variable in the test,
  `E` could be assigned a negative value and the run aborted on `Model error:
  Argument of log(E / F) was -0.00694498 should be > 0`. The liquid-side guard
  a few lines above tests `Bliq`, which is what the vapour side meant.
- Both fugacity expressions carry a prefactor `A / (B * sqrt(8))`. Outside the
  two-phase region MaterialStream zeroes one phase's composition, which sends
  that phase's `aM` and `bM` — and so its `A` and `B` — to zero, and the
  unguarded quotient evaluates `0/0`. A Peng-Robinson stream would therefore
  solve inside the two-phase envelope and fail with `Iteration variable
  ... is inf or nan` the moment it was asked for a subcooled liquid or a
  superheated vapour. The prefactor is now zeroed when the phase is absent,
  which leaves that phase a fugacity coefficient of 1 — a value nothing in the
  single-phase branches reads.

---

## 5. Flash closure: Rachford-Rice instead of `sum(y) = 1`

`Streams/MaterialStream.mo`, two-phase branch. Upstream closed the flash with

```modelica
sum(x_pc[3, :]) = 1;                    // sum(y) = 1
```

alongside `y_i = K_i x_i` and `x_i = z_i / (1 + xvap (K_i - 1))`. Substitute and
that equation reads

```
sum( z_i K_i / (1 + xvap (K_i - 1)) ) = 1
```

which at `xvap = 1` collapses to `sum(z_i) = 1` **for any set of K-values
whatsoever**. So the system always has a second, spurious root at "all vapour"
sitting next to the physical one, and a solver started away from the answer can
converge on it. Raoult's law usually starts close enough to miss it.
Peng-Robinson does not: a propane / n-butane / n-pentane feed at 5 bar and 320 K
returns `xvap = 1.0` with a liquid composition of `z_i / K_i` — a dew-point
state, silently reported as a flash.

The closure is now the Rachford-Rice form:

```modelica
sum(x_pc[3, :]) = sum(x_pc[2, :]);      // sum(y) = sum(x)
```

The two are equivalent at every genuine solution. From the definitions,
`xvap * sum(y) + (1 - xvap) * sum(x) = sum(z) = 1` identically, so `sum(y) =
sum(x)` forces both to 1, and conversely `sum(y) = 1` forces either `sum(x) = 1`
or `xvap = 1`. Rachford-Rice keeps the first case and rejects the second, unless
`sum(z_i / K_i) = 1` — which is the definition of an actual dew point. Same
physical root, one fewer place for the solver to land. The same feed now returns
`xvap = 0.924`.

`Examples/Absorption` is the exception, and it keeps the old closure via
`rachfordRice = false` on its four streams. It is the most fragile model in the
suite — a permanent gas in the mixture, and the one example that needs explicit
guess anchors to converge at all (see §2) — and on OpenModelica 1.27.0 the new
closure moves the Newton path enough that it fails at `S4.x_pc[1,2] is inf or
nan`. The parameter is on `MaterialStream`, defaults to `true`, and exists for
that one model.

---

## 6. Ported from MSL 3.2.3 to MSL 4.x

Upstream targeted the Modelica Standard Library 3.2.x. Two names it depends on
were moved in MSL 4.0, and 4.x is what OpenModelica now loads by default, so the
library was ported rather than left pinned to a version users have to go and
select by hand.

- `Simulator/package.mo`: `import SI = Modelica.SIunits` and
  `import Cv = Modelica.SIunits.Conversions` became `Modelica.Units.SI` and
  `Modelica.Units.Conversions`. Both imports are in fact unused — nothing in the
  library references `SI.` or `Cv.` — but an unresolvable import is still an
  error waiting to happen, and leaving them pointing at a package that no longer
  exists would be misleading.
- `Modelica.Math.Vectors.Utilities.roots` was removed in MSL 4.0; the same
  function, with the same signature, is now `Modelica.Math.Polynomials.roots`.
  Five call sites: `PengRobinson` (2), `GraysonStreed` (2),
  `BinaryPhaseEnvelopePR` (1). Symptom if this patch is lost:

  ```
  Function Modelica.Math.Vectors.Utilities.roots not found in scope PengRobinson.
  ```

Nothing else in the library touches an MSL name that changed: `Modelica.Icons.*`,
`Modelica.Constants.*`, `Modelica.Math.Nonlinear.quadratureLobatto`,
`Modelica.Math.BooleanVectors.firstTrueIndex` and `Modelica.Media.Water` are all
present and unchanged in 4.x.

**The port is one-way.** `Modelica.Math.Polynomials` does not exist in 3.2.3, so
loading this library against it now fails. That is deliberate — one supported
configuration is easier to keep working than two.

---

## Verifying

```
python tools/run_regression.py --check-only   # translate every model
python tools/run_regression.py                # translate and simulate
```

The harness covers all 35 executable examples in this library plus the
repository's own models, and both invocations are expected to report every one
of them passing on OpenModelica 1.27.0 + MSL 4.1.0. Run it before and after
changing anything here, and diff the two summaries.

## Known remaining constraint

None outstanding. `omc` resolves a requested MSL version as a minimum within a
major release rather than an exact pin — asking for `{"4.0.0"}` on a machine
that also has 4.1.0 installed gets you 4.1.0 — so `MSL_VERSION` in the
regression harness documents the intent more than it enforces it.
