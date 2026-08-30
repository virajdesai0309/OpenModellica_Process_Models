# Building models against the patched OMChemSim

Notes for writing your own flowsheets on top of `vendor/OMChemSim-v1.0`, and
for keeping them working as OpenModelica moves on.

Verified against **OpenModelica 1.27.0** with **MSL 3.2.3**.

---

## 1. Load the library with MSL 3.2.3

OMChemSim uses `Modelica.SIunits`, which MSL 4.x renamed to `Modelica.Units.SI`.
Until the library is ported, it must be loaded against 3.2.3.

In OMEdit: *Tools → Options → Libraries* → set the Modelica system library
version to `3.2.3`. From a script:

```modelica
loadModel(Modelica, {"3.2.3"});
loadFile("<repo>/vendor/OMChemSim-v1.0/Simulator/package.mo");
```

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

`xg_user` need not be normalised. Both parameters affect start values only; they
cannot change the converged solution, so setting them is always safe. See
`Simulator.Examples.Absorption` for a worked case — it does not converge without
them.

Symptoms that point here rather than at a modelling error:

```
Iteration variable `S4.x_pc[1,2]` is inf or nan
Invalid root: (18.8383)^(27009.3)
```

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

`vendor/OMChemSim-v1.0/ATTRIBUTION.md` records every patch and the error it
fixes, which is the fastest way to tell a new problem from a known one.
