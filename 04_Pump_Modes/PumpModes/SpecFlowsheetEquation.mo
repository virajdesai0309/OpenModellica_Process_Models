within PumpModes;

model SpecFlowsheetEquation "Duty set by an equation in the flowsheet (the original library style)"
  extends Modelica.Icons.Example;
  extends PumpModes.PumpFlowsheet(B1(spec = Simulator.Files.Types.PumpSpec.OutletPressure, Pout_spec = 5e5));

  parameter Real Pdel_target(unit = "Pa", displayUnit = "bar") = 398675 "Pressure increase to impose";

equation
/* B1.spec is left at its default, FlowsheetEquation, under which the pump
   contributes no closing equation of its own. The flowsheet supplies one
   instead -- which is how every model written against upstream OMChemSim
   specifies a pump, and why that default exists. Any one of B1.Pdel, B1.Pout
   or B1.Q would do. */
  B1.Pdel = Pdel_target;

  annotation(
    Documentation(info = "<html><head></head><body><div>Specifies the pump by writing an equation in the flowsheet, leaving <code>B1.spec</code> at its default of <b>FlowsheetEquation</b>. This is the style every model written against the original OMChemSim library uses, and it still works unchanged.</div><div><br></div><div>Compare with <a href=\"modelica://PumpModes.SpecPressureIncrease\">SpecPressureIncrease</a>, which imposes the same pressure rise from the pump's own parameter dialog instead. The two return identical results.</div><div><br></div><div><b>Do not do both.</b> Setting <code>B1.spec</code> to a mode <i>and</i> writing a duty equation here over-determines the model.</div></body></html>"),
    experiment(StopTime = 1, Interval = 1));
end SpecFlowsheetEquation;
