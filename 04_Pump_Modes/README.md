# 04 — Pump calculation modes

Four flowsheets, identical except for **how the pump's duty is specified**. They
all pump the same feed to the same outlet pressure, so they must all return the
same answer. That is what makes this a test rather than a demonstration.

## The case

Pure water, 100 mol/s, 101325 Pa, 300 K, Raoult's law. A centrifugal pump at
75 % efficiency raises it to 5 bar.

Water alone keeps the thermodynamics out of the way: for a single component
bubble and dew pressure coincide, the stream is unambiguously liquid at these
conditions, and the K-value corrections a non-ideal package would apply cancel
out of the flash entirely. Anything that moves between the four models is the
pump, not the property method.

## The four models

| Model | `B1.spec` | How the duty is given |
| --- | --- | --- |
| [`SpecFlowsheetEquation`](PumpModes/SpecFlowsheetEquation.mo) | `FlowsheetEquation` (default) | `B1.Pdel = 398675;` written in the flowsheet |
| [`SpecOutletPressure`](PumpModes/SpecOutletPressure.mo) | `OutletPressure` | `Pout_spec = 500000` in the pump's dialog |
| [`SpecPressureIncrease`](PumpModes/SpecPressureIncrease.mo) | `PressureIncrease` | `Pdel_spec = 398675` in the pump's dialog |
| [`SpecPowerRequired`](PumpModes/SpecPowerRequired.mo) | `PowerRequired` | `Q_spec = 961.6676` in the pump's dialog |

All four extend [`PumpFlowsheet`](PumpModes/PumpFlowsheet.mo), a partial model
holding the feed, pump, discharge stream and energy stream. It is one equation
short on purpose — the duty is exactly the degree of freedom each model closes
differently, so `PumpFlowsheet` itself cannot be simulated.

## Expected result

Common to all four, agreeing to about 1e-13 relative:

| | |
| --- | --- |
| Outlet pressure | 500000 Pa |
| Pressure increase | 398675 Pa |
| Shaft power | 961.668 W |
| Outlet temperature | 300.1289 K |
| NPSH available | 10.0133 m |
| Vapour fraction | 0 (liquid throughout) |

## What each model is guarding

- **`SpecFlowsheetEquation`** is the backwards-compatibility guarantee. The
  `FlowsheetEquation` default must contribute no equation of its own, or every
  model written against the original OMChemSim library — which specifies pumps
  exactly this way — becomes over-determined. If someone later gives that
  default a closing equation, this model fails first.
- **`SpecPowerRequired`** is the physics guarantee. It is the only mode that
  runs the energy balance backwards: given nothing but the shaft power, it must
  recover the pressure rise from `Q = Fin*(Hout - Hin)` and
  `Hout = Hin + Pdel/(rho*Eff)`. Against the upstream form of that balance,
  which divided by `Eff` a second time and let the friction heat vanish, this
  model would come back 25 % off. See section 7 of the library's
  `ATTRIBUTION.md`.

## Running them

```
python tools/run_regression.py --filter PumpModes
```

Or open `04_Pump_Modes/PumpModes/package.mo` in OMEdit alongside the `Simulator`
library and simulate any of the four.
