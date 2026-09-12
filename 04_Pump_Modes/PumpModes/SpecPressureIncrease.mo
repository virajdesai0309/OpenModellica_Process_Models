within PumpModes;

model SpecPressureIncrease "Duty set by the pump's specified pressure increase"
  extends Modelica.Icons.Example;
  extends PumpModes.PumpFlowsheet(
    B1(spec = Simulator.Files.Types.PumpSpec.PressureIncrease, Pdel_spec = 398675));

  annotation(
    Documentation(info = "<html><head></head><body><div>The pump adds a specified <b>pressure increase</b> of 398675 Pa to the inlet, set on the block itself under <b>Pump Specifications &rarr; Calculation Mode</b>. The flowsheet writes no duty equation.</div><div><br></div><div>This is the dialog-driven equivalent of <a href=\"modelica://PumpModes.SpecFlowsheetEquation\">SpecFlowsheetEquation</a>, which imposes the same rise with a hand-written equation. The two return identical results.</div></body></html>"),
    experiment(StopTime = 1, Interval = 1));
end SpecPressureIncrease;
