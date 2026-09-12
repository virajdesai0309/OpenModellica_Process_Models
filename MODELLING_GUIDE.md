# Building models against the patched OMChemSim

Notes for writing your own flowsheets on top of `vendor/OMChemSim-v1.0`, and
for keeping them working as OpenModelica moves on.

Verified against **OpenModelica 1.27.0** with **MSL 4.1.0**.

---

## 1. Load the library with MSL 4.x

The vendored copy is ported to the Modelica Standard Library 4.x and **will not
compile against 3.2.3** — it uses `Modelica.Units.SI` (renamed from
`Modelica.SIunits` in 4.0) and `Modelica.Math.Polynomials.roots` (moved out of
`Modelica.Math.Vectors.Utilities` in 4.0).

4.x is what OpenModelica loads by default, so in OMEdit there is usually nothing
to change. If you have previously pinned 3.2.3 for this library, undo it:
*Tools → Options → Libraries* → set the Modelica system library back to `4.1.0`.
From a script:

```modelica
loadModel(Modelica, {"4.1.0"});
loadFile("<repo>/vendor/OMChemSim-v1.0/Simulator/package.mo");
```

Load the standard library **first**. `loadFile` on the process library will pull
in whatever `Modelica` is already resolved, and by then it is too late to choose.

> `omc` treats the version as a minimum within a major release, not an exact
> pin: ask for `{"4.0.0"}` on a machine that also has 4.1.0 and you get 4.1.0.
> Across a major version it is exact, so `{"3.2.3"}` really does load 3.2.3 —
> and then the library fails on `Modelica.Math.Polynomials not found`.

---

## 2. A stream needs a thermodynamic package mixed into it

`Simulator.Streams.MaterialStream` on its own is incomplete — it consumes
K-values and residual properties that a property package has to supply. Combine
the two.

**Recommended (`Nc` and `C` written once):** define the composite with
unmodified `extends`, then specify the components where you use it.

```modelica
package MyModels
  import data = Simulator.Files.ChemsepDatabase;

  partial model MS "Material stream + Raoult's Law"
    extends Simulator.Streams.MaterialStream;
    extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;
  end MS;

  model MyFirstStream
    parameter data.Ethanol eth;
    parameter data.Water wat;
    extends MS(Nc = 2, C = {eth, wat});
  equation
    P = 101325;
    T = 350;
    x_pc[1, :] = {0.4, 0.6};
    F_p[1] = 100;
  end MyFirstStream;
end MyModels;
```

**Also valid (single self-contained model):** repeat `Nc` and `C` on *both*
`extends` clauses.

```modelica
extends Simulator.Streams.MaterialStream(Nc = 2, C = {eth, wat});
extends Simulator.Files.ThermodynamicPackages.RaoultsLaw(Nc = 2, C = {eth, wat});
```

**Not valid** — the modification on only one branch:

```modelica
extends Simulator.Streams.MaterialStream(Nc = 2, C = {eth, wat});
extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;   // <-- error
```

```
Error: Duplicate elements (due to inherited elements) not identical:
  first element is:  parameter GeneralProperties[Nc] C = {eth, wat}
  second element is: parameter GeneralProperties[Nc] C
```

`Nc` and `C` are inherited through both branches, and Modelica requires
duplicate inherited elements to be identical. Put the modification below the
join, or on both sides of it.

The same rule applies to any unit operation you mix a property package into
(Flash, ShortcutColumn, the column internals, CSTR), and to reactors mixed with
a reaction definition.

---

## 3. Specifying a stream

A material stream needs exactly four specifications. The usual sets:

| Flash type | Specify |
|---|---|
| TP  | `P`, `T`, `x_pc[1, :]`, `F_p[1]` |
| TVF | `T`, `xvap`, `x_pc[1, :]`, `F_p[1]` |
| PVF | `P`, `xvap`, `x_pc[1, :]`, `F_p[1]` |
| PH  | `P`, `H_p[1]`, `x_pc[1, :]`, `F_p[1]` |
| PS  | `P`, `S_p[1]`, `x_pc[1, :]`, `F_p[1]` |

Worked examples of each: `Simulator.Examples.MaterialStream`.

Array index conventions, used throughout the library:

- `_p[3]` → phase: `1` mixture, `2` liquid, `3` vapour.
- `_c[Nc]` → component.
- `_pc[3, Nc]` → phase then component.

So `F_p[2]` is the liquid molar flow and `x_pc[3, 1]` is the vapour mole
fraction of component 1.

---

## 4. Available property packages

`Simulator.Files.ThermodynamicPackages.` — `RaoultsLaw`, `NRTL`, `UNIQUAC`,
`UNIFAC`, `PengRobinson`, `GraysonStreed`.

`RaoultsLaw` assumes an ideal liquid solution and an ideal gas, so it cannot
reproduce azeotropes. Ethanol–water has one at roughly 0.89 mole fraction
ethanol; if you are working near it, use `NRTL` or `UNIQUAC`.

### Peng-Robinson, specifically

No upstream example put `PengRobinson` on a material stream, so it arrived with
three bugs that only appear when you do (all fixed here — see ATTRIBUTION §4).
What is left is a working cubic equation of state with one limitation worth
knowing before you plan a study around it:

| Where the stream sits | Peng-Robinson |
|---|---|
| Inside the two-phase envelope | reliable |
| Above the dew point (superheated) | reliable |
| Below the bubble point (subcooled liquid) | **does not converge** |

The subcooled case fails in the initialisation solve, not in the physics: the
flash equations are still live in that branch, and the solver cannot find its
way in from the guesses the library derives. `Simulator.Examples.MaterialStream`
does not cover it either, so treat the bubble point as the working edge for now.

**Check `xvap` lands in [0, 1].** Two things conspire against it. `Pbubl` and
`Pdew` — the test that picks the phase region — are computed in `MaterialStream`
from vapour pressures and the activity and fugacity coefficients the package
supplies at the bubble and dew points; `PengRobinson` sets all four of those to
1, so the *envelope* is Raoult's while the *flash inside it* is Peng-Robinson.
And the Rachford-Rice closure has roots outside [0, 1] that Newton can reach.
Together they let a converged run report something like `xvap = 3.49` at a point
the ideal envelope calls two-phase. Nothing errors; the number is simply not a
vapour fraction. A different `xvap` start value usually finds the physical root
— `tools/run_doe.py` checks the bound and retries automatically.

`03_Multi_Stream/MultiStream.mo` is a worked Peng-Robinson stream.

---

## 4a. Mixing OMChemSim with Modelica.Media in one model

OMChemSim is not the only source of properties available, and for some streams
it is not the best one. The Modelica Standard Library ships `Modelica.Media`,
whose `Water.StandardWater` is the IAPWS-IF97 steam tables. It is a
single-substance medium — no composition, no flash — but for water it is far
more accurate than any cubic equation of state, over a far wider range.

Both can live in one model. They do not share a stream type, so what you write
is two independent streams that happen to be solved together:

```modelica
model SteamStream
  package Medium = Modelica.Media.Water.StandardWater;
  Real P(start = 101325), T(start = 373.15), F(start = 100);   // specify these
  Medium.ThermodynamicState state;
equation
  state = Medium.setState_pT(P, T);
  // Medium.specificEnthalpy(state), .density(state), .saturationTemperature(P) ...
end SteamStream;
```

Three things to watch when the two meet:

- **`setState_pT` cannot represent a two-phase state.** On the saturation line
  pressure and temperature are not independent. IF97 resolves the region by
  comparing `T` against `Tsat(P)`, so a point exactly on the line is undefined
  and a point either side is single-phase. A wet-steam stream has to be
  specified as `(P, h)` or `(P, x)`.
- **Reference states differ.** IF97 zeroes enthalpy and entropy at the triple
  point liquid; OMChemSim's `HLiqId` / `HVapId` integrate an ideal-gas Cp from
  298.15 K and ignore the standard enthalpy of formation they are handed.
  Differences between two states are comparable; absolute values are not.
- **Units differ.** OMChemSim carries molar flow in mol/s and molecular weight
  in kg/kmol, so `Fm_p` comes out in **grams** per second despite being declared
  `kg/s`. `Modelica.Media` is strict SI throughout. Convert at the seam.

---

## 5. If the solver will not converge

Start values come from `Simulator.GuessModels.InitialGuess`, which derives them
from the component set alone: it computes the mixture's bubble and dew
temperature at `Pg` and flashes an equimolar feed midway between them. That is a
good neutral guess for an ordinary VLE mixture and needs no help.

It is a poor guess in two situations, and both have an explicit lever.

**A permanent gas in the mixture.** Air's vapour-pressure correlation
extrapolated to 1 atm crosses at 78.6 K, so an acetone/air/water absorber gets a
derived bubble temperature of 90 K and a guess near 220 K — while the column
runs at 330 K. Anchor the temperature:

```modelica
MyColumn B1(Nc = Nc, C = C, Tg_user = 330);
```

**A composition far from equimolar** — a dilute absorber, a near-pure solvent:

```modelica
MS S1(Nc = Nc, C = C, xg_user = {0, 0, 1});   // pure water solvent
```

**A Peng-Robinson flash away from an even split.** `Tg_user` and `xg_user` seed
the derived guesses, but the vapour fraction they produce assumes an equimolar
feed, and Peng-Robinson is far less forgiving about it than Raoult. Set the
start attribute directly:

```modelica
MS_PR S1(Nc = Nc, C = C, xvap(start = 0.9));   // mostly vapour
```

`Simulator.Examples.MaterialStream.UNIQUAC` does the same thing for the same
reason. If a point will not solve, try a few values across `[0, 1]` before
concluding there is no solution — `tools/run_doe.py --retry` automates exactly
that.

`xg_user` need not be normalised. All of these affect start values only; they
cannot change the converged solution, so setting them is always safe. See
`Simulator.Examples.Absorption` for a worked case — it does not converge without
them.

Symptoms that point here rather than at a modelling error:

```
Iteration variable `S4.x_pc[1,2]` is inf or nan
Invalid root: (18.8383)^(27009.3)
```

---

## 5a. Parametric studies and design of experiments

A stream model here is algebraic — no `der()` anywhere — so "simulating" it is
one steady-state solve, and moving the operating point is the only interesting
thing to do with it. There are two ways, and they fail differently.

### Over simulation time, inside the model

Make the specification a function of `time` and every output interval is another
steady-state solve, seeded from the previous one:

```modelica
tau = (time - t_start) / (t_stop - t_start);
S1.T = T_start + tau * (T_end - T_start);
```

The continuation is the point: each step starts from the last answer, which is
much better than any guess the library can derive. `MultiStream.StreamSweep` is
a worked example.

The catch is structural. With `T` and `P` as parameters the compiler can resolve
the phase-region `if` before the solver runs; drive them from `time` and all
three branches stay live, which makes the initial system much larger. In that
form a Peng-Robinson stream needs an explicit `xvap` start value to initialise
at all, will not start from a single-phase point, and does not switch region
reliably partway through a sweep. **Keep a time sweep inside one phase region.**

### Over a grid, outside the model

`buildModel` once, then run the generated executable per point with `-override`:

```bash
omc -e 'loadModel(Modelica,{"4.1.0"}); loadFile("..."); buildModel(MyModel, outputFormat="csv")'
./MyModel -override=P=5e5,T=320 -r=point1.csv
```

One compile instead of one per point. Three things to know:

- `outputFormat` is fixed **at build time**. `-r=whatever.csv` only names the
  file; without `outputFormat = "csv"` on `buildModel` you get a binary `.mat`
  with a misleading name.
- The generated executable needs OpenModelica's `bin` (and its bundled
  `tools/msys/mingw64/bin` on Windows) on `PATH`, or it dies with
  `error while loading shared libraries`.
- Bind the guess anchors to the specification — `Pg = P_spec`,
  `Tg_user = T_spec` — so an overridden operating point gets start values that
  follow it instead of ones frozen at the compiled-in defaults.

`tools/run_doe.py` does all of this, plus retrying a failed point with different
start values and filtering out compositions that do not sum to something
physical.

---

## 6. Checking your model still works after an OpenModelica upgrade

```
python tools/run_regression.py --check-only   # translate all models (fast)
python tools/run_regression.py                # translate and simulate
```

The harness compiles every executable example in the vendored library plus your
own models, and exits non-zero if anything regressed. Add your models to
`LOCAL_MODELS` in `tools/run_regression.py` as you write them:

```python
LOCAL_MODELS = [
    (os.path.join(REPO, "01_Material_Stream", "MyModels.mo"), "MyModels.MyFirstStream"),
    (os.path.join(REPO, "03_Multi_Stream", "MultiStream.mo"), "MultiStream.TwoStreams"),
]
```

Run it before and after upgrading OpenModelica and diff the two summaries. If
the new version tightens another rule, you will see exactly which models it
affects instead of discovering it one simulation at a time.

---

## 7. Reading OpenModelica errors against this library

Patterns worth recognising, with what they usually mean here:

| Message | Cause |
|---|---|
| `Duplicate elements (due to inherited elements) not identical` | modification on one branch of a stream+package join — see §2 |
| `Variable X not found in scope Y` | a cross-reference between two mixed-in halves; the name needs to live in `PartialThermoInterface` or `PartialReactionInterface` |
| `Non-array modification '...' for array component` | a scalar modifier on an array component; add `each` |
| `Too few equations, under-determined system` | a mixed-in interface variable that nothing constrains, or a missing specification |
| `The initial conditions are over specified` | an `initial equation` section inherited through more than one path |
| `division by zero ... divisor Psatt[n]` | the old guess system; should not occur any more (see ATTRIBUTION §2) |
| `refers to a component with a false condition` | a conditional component used outside a `connect` |
| `Iteration variable X.x_pc[3,n] is inf or nan` | a flash that will not initialise. On Peng-Robinson, usually a subcooled point (see §4) or a missing `xvap` start value; otherwise a guess anchor, see §5 |
| `Argument of log(E / F) was ... should be > 0` | a Peng-Robinson guard bug, fixed here — if you see it, the vendored patch has been lost |
| `GUID ... does not match the GUID compiled in the model` | a stale `<Model>_init.xml` in the working directory from an earlier build; delete it |
| `error while loading shared libraries: api-ms-win-crt-*.dll` | running a generated executable without OpenModelica's `bin` on `PATH`, see §5a |

`vendor/OMChemSim-v1.0/ATTRIBUTION.md` records every patch and the error it
fixes, which is the fastest way to tell a new problem from a known one.
