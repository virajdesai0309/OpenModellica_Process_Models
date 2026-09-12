# 03 — Material streams: two property methods in one model

Companion models for **Guide 01, Material Stream Modelling in OpenModelica**.

A material stream is where OpenModelica stops being a general equation solver and starts being a process simulator. The stream itself is only a few specifications — pressure, temperature, flow, composition — but behind it sits a flash calculation, and behind *that* sits a property method. Change the property method and the same four specifications give you different answers.

This folder builds three things:

| Model | What it is |
| --- | --- |
| `MultiStream.TwoStreams` | One hydrocarbon stream on **Peng-Robinson** and one water stream on the **IF97 steam tables**, solved side by side at a fixed operating point |
| `MultiStream.StreamSweep` | The same pair with the operating point walked over simulation time — a one-factor-at-a-time response curve |
| `MultiStream.SteamStream` | The water stream on its own; a thin wrapper over `Modelica.Media.Water.StandardWater` shaped like an OMChemSim stream |

---

## Why two libraries at once

The obvious question is why not do both streams the same way. The answer is that neither library can do the other's job.

**OMChemSim** (in [vendor/](../vendor/)) understands *composition*. `Simulator.Streams.MaterialStream` mixed with a thermodynamic package gives you K-values, a bubble pressure, a dew pressure, a vapour fraction and phase compositions for a mixture of any number of components. That is what you need for a hydrocarbon cut.

**`Modelica.Media`** (in the Modelica Standard Library) understands *one substance, very accurately*. `Water.StandardWater` is the IAPWS-IF97 industrial formulation — the steam tables, as an equation of state. It has no composition to speak of, and it is not going to flash a three-component NGL for you. What it will do is give you the density of superheated steam at 40 bar to a precision no cubic equation of state gets near.

A steam-traced hydrocarbon line has one of each. So does almost every real flowsheet.

```
                    OMChemSim                     Modelica.Media
                        │                                │
   Composites.MS_PR ────┤                                ├──── SteamStream
   (MaterialStream                                       (StandardWater,
    + PengRobinson)     │                                │      IF97)
                        └────────► TwoStreams ◄──────────┘
                                        │
                                   both streams,
                                   one result file
```

---

## Running it

### From the command line

From the **repository root**, not from this folder:

```bash
omc 03_Multi_Stream/run.mos
```

That loads MSL 4.1.0, loads OMChemSim, loads these models, and simulates both `TwoStreams` and `StreamSweep` to CSV.

### In OMEdit

Order matters, and getting it wrong produces errors that look like language problems rather than loading problems:

1. **Tools → Options → Libraries** — the Modelica system library must be **4.x** (4.1.0 is the default, so normally there is nothing to do). The vendored OMChemSim is ported to `Modelica.Units.SI` and `Modelica.Math.Polynomials`, neither of which exists in 3.2.3.
2. **File → Open Model/Library File** → `vendor/OMChemSim-v1.0/Simulator/package.mo`
3. **File → Open Model/Library File** → `03_Multi_Stream/MultiStream.mo`
4. Select `MultiStream.TwoStreams` and press **Simulate**.

If step 3 reports unresolved names, step 1 or step 2 did not happen.

---

## What comes out

At the shipped operating point — hydrocarbon at 5 bar / 320 K, water at 10 bar / 500 K:

| | Hydrocarbon stream `HC` | Water stream `W` |
| --- | --- | --- |
| Feed | C3 0.50 / nC4 0.30 / nC5 0.20, 100 mol/s | pure H₂O, 100 mol/s |
| Property method | Peng-Robinson | IAPWS-IF97 |
| Bubble pressure | 9.70 bar | — |
| Dew pressure | 4.26 bar | — |
| Saturation temperature | — | 453.0 K |
| Phase | two-phase, `xvap` = 0.924 | superheated by 47.0 K |
| K-values | 2.90 / 0.969 / 0.342 | — |
| Enthalpy | 457 kJ/kmol | 2891 kJ/kg |

Read the two enthalpies with care. **They are on different reference states**: IF97 puts zero at saturated liquid water at the triple point, while OMChemSim's ideal-gas enthalpy correlations put zero at 298.15 K. Differences between two states of the same stream are meaningful; the absolute numbers are not comparable across the two columns.

The mass flows have a seam too. OMChemSim carries molar flow in mol/s and molecular weight in kg/kmol, so its `Fm_p` is numerically **grams** per second despite being declared `kg/s`. `TwoStreams.Fm_hc` does the conversion before adding it to the water stream's genuine kg/s.

---

## Sweeping the operating point

### In the model, over time — `StreamSweep`

Neither stream has a derivative in it. `StreamSweep` is therefore not a dynamic model: it is a sequence of steady-state solves with the specification moved a little between each, which makes it a one-factor-at-a-time experiment. Set the `_start` / `_end` pair of the factor you want to vary, leave the others equal:

```modelica
model MySweep
  extends MultiStream.StreamSweep(T_hc_start = 305, T_hc_end = 318);
end MySweep;
```

As shipped it walks the hydrocarbon feed from 305 K to 318 K at 5 bar, giving `xvap` from 0.465 to 0.866 — a boiling curve — while the water goes from 460 K to 700 K at 10 bar. Plot `HC.xvap` against `HC.T`, and `W.h` or `W.d` against `W.T`.

> [!IMPORTANT]
> **Start the sweep inside the two-phase envelope, and keep it there.**
>
> Driving `T` and `P` from `time` keeps all three phase-region branches live at once, which makes the initial solve much larger than the fixed-point version. Two consequences, both observed:
>
> - Peng-Robinson needs the `xvap_guess` start value to initialise at all, and a sweep whose **first** point is a subcooled liquid or a superheated vapour will not start.
> - A sweep that *crosses* a phase boundary partway does run, but the branch switch does not reliably fire — `xvap` carries on past 1 instead of the model changing region, and the run stops short of the stop time.
>
> This is a limitation of the flash formulation in the vendored library, not of the idea. Keep a sweep inside one region and it is well behaved; for anything wider, use the grid below.

### Over a grid — `tools/run_doe.py`

A proper factorial design lives outside the model. [tools/run_doe.py](../tools/run_doe.py) compiles `TwoStreams` **once** and then re-runs the executable per grid point with `-override`, which is what makes a hundred-point study cost one compile instead of a hundred:

```bash
# the built-in grid: P x T x composition for the hydrocarbon, P x T for the water
python tools/run_doe.py

# or your own factors, full factorial over whatever you list
python tools/run_doe.py --factor T_hc=300,310,320 \
                        --factor P_hc=3e5,5e5,8e5 \
                        --factor z_c3=0.3,0.5,0.7
```

Results land in `doe_results.csv` next to this file, one row per solved point. The shipped grid is 3 × 3 × 3 × 2 × 3 = 162 points and returns **138** of them; the 24 it drops are four hydrocarbon states at the cold and low-pressure edges, each repeated over the six water conditions. Widening the start-value list does not recover them — 13 values across [0, 1] were tried — so they are the library's limit rather than a bad guess.

Four things it does that a bare loop would not:

- **Drops infeasible compositions.** Sweeping two mole fractions independently over a three-component feed generates combinations whose balance is negative. Those are bad specifications, not convergence failures, and mixing the two makes the output hard to read.
- **Checks that the answer is physical, not just converged.** A run can finish cleanly and report `HC.xvap = 3.49`. Two things allow it: the Rachford-Rice closure has roots outside `0 ≤ xvap ≤ 1` that Newton can reach, and the phase-region test does not catch it because `MaterialStream` computes `Pbubl` and `Pdew` from Raoult's law whatever property package is mixed in — so the *envelope* is ideal while the *flash inside it* is Peng-Robinson, and near the disagreement the two do not line up. Out-of-range results are rejected rather than written to the CSV.
- **Retries with a different start value.** A point that does not converge — or that converges on one of those non-physical roots — is usually a bad guess rather than a state with no solution. Each failing point is retried down the `--retry` list. Start values cannot change the answer, only whether the solver finds it.
- **Reports what did not solve.** Failures are listed at the end rather than silently dropped. Finding the edge of the operating envelope is half the reason to run the grid.

---

## Files

| File | |
| --- | --- |
| [MultiStream.mo](MultiStream.mo) | The models — composites, `SteamStream`, `TwoStreams`, `StreamSweep` |
| [run.mos](run.mos) | Load both libraries and simulate, from the repository root |
| `doe_results.csv` | Written by `tools/run_doe.py` |

## See also

- [MODELLING_GUIDE.md](../MODELLING_GUIDE.md) — how to write your own models against the patched OMChemSim: the stream + package join, the four specifications a stream needs, guess anchors, and how to read the errors
- [vendor/OMChemSim-v1.0/ATTRIBUTION.md](../vendor/OMChemSim-v1.0/ATTRIBUTION.md) — every patch applied to the vendored library and the error it fixes
