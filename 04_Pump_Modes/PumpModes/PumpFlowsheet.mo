within PumpModes;

partial model PumpFlowsheet "Feed, pump and outlet stream, with the pump duty left unspecified"
  import data = Simulator.Files.ChemsepDatabase;

  //--- Component system: water alone -----------------------------------------
  parameter data.Water wat;
  parameter Integer Nc = 1 "Number of components";
  parameter data.GeneralProperties C[Nc] = {wat} "Component instances";

  //--- Feed specification, shared by all four models --------------------------
  parameter Real Fin_spec(unit = "mol/s") = 100 "Feed molar flow";
  parameter Real Pin_spec(unit = "Pa", displayUnit = "bar") = 101325 "Feed pressure";
  parameter Real Tin_spec(unit = "K") = 300 "Feed temperature";
  parameter Real Eff_spec(unit = "-") = 0.75 "Pump efficiency";

  /* Tg_user pins the start-value temperature to the operating point. Without
     it, InitialGuess derives a guess from the component set as the midpoint of
     the mixture's bubble and dew temperatures at Pg -- which for pure water at
     1 atm is 373 K, since bubble and dew coincide for a single component. The
     pump runs at 300 K, so the guess would be 73 K away from the answer. This
     only moves start values; it cannot change the converged solution. */
  PumpModes.WaterStream S1(Nc = Nc, C = C, Tg_user = Tin_spec) "Feed stream" annotation(
    Placement(visible = true, transformation(origin = {-70, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.UnitOperations.CentrifugalPump B1(Nc = Nc, C = C, Tg_user = Tin_spec, Eff = Eff_spec) "Pump" annotation(
    Placement(visible = true, transformation(origin = {0, -2}, extent = {{-14, -14}, {14, 14}}, rotation = 0)));
  PumpModes.WaterStream S2(Nc = Nc, C = C, Tg_user = Tin_spec) "Discharge stream" annotation(
    Placement(visible = true, transformation(origin = {64, 12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Streams.EnergyStream E1 "Shaft power" annotation(
    Placement(visible = true, transformation(origin = {-38, -44}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

equation
  connect(S1.Out, B1.In) annotation(
    Line(points = {{-60, 0}, {-14, 0}}, color = {0, 70, 70}));
  connect(B1.Out, S2.In) annotation(
    Line(points = {{14, 12}, {54, 12}}, color = {0, 70, 70}));
  connect(E1.Out, B1.En) annotation(
    Line(points = {{-28, -44}, {0, -44}, {0, -12}}, color = {255, 0, 0}));

//--- Feed specification ------------------------------------------------------
  S1.F_p[1] = Fin_spec;
  S1.x_pc[1, :] = {1.0};
  S1.P = Pin_spec;
  S1.T = Tin_spec;

/* The pump's duty is deliberately NOT specified here. This model is one
   equation short and cannot be simulated; each of the four models that extend
   it closes that degree of freedom a different way. */
  annotation(
    Documentation(info = "<html><head></head><body><div>The flowsheet every model in this package shares: a pure-water feed, a centrifugal pump, a discharge stream and an energy stream carrying the shaft power.</div><div><br></div><div><b>This model is partial and cannot be simulated.</b> It is exactly one equation short, because the pump's duty is left unspecified — that is the degree of freedom the four models extending it each close differently.</div></body></html>"),
    Diagram(coordinateSystem(extent = {{-100, -60}, {100, 40}})));
end PumpFlowsheet;
