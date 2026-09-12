within PumpModes;

model SpecOutletPressure "Duty set by the pump's specified outlet pressure"
  extends Modelica.Icons.Example;
  extends PumpModes.PumpFlowsheet(
    B1(spec = Simulator.Files.Types.PumpSpec.OutletPressure, Pout_spec = 500000));

  annotation(
    Documentation(info = "<html><head></head><body><div>The pump raises the stream to a specified <b>outlet pressure</b> of 500000 Pa (5 bar), set on the block itself under <b>Pump Specifications &rarr; Calculation Mode</b>. The flowsheet writes no duty equation.</div><div><br></div><div>Because the feed is at 101325 Pa, this is the same duty as the 398675 Pa rise imposed by <a href=\"modelica://PumpModes.SpecPressureIncrease\">SpecPressureIncrease</a>, and the results are identical.</div></body></html>"),
    experiment(StopTime = 1, Interval = 1));
end SpecOutletPressure;
