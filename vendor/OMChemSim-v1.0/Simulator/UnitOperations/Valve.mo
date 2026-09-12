within Simulator.UnitOperations;

model Valve "Model of a valve to regulate the pressure of a material stream"
  extends Simulator.Files.Icons.Valve;
  //====================================================================================
  Real Fin(unit = "mol/s", min = 0, start = Fg) "Inlet stream molar flow rate";
  Real Pin(unit = "Pa", min = 0, start = Pg) "Inlet stream pressure"; 
  Real Tin(unit = "K", min = 0, start = Tg) "Inlet stream emperature";
  Real Hin(unit = "kJ/kmol",start=Htotg) "Inlet stream molar enthalpy"; 
  Real Sin(unit = "kJ/[kmol.K]") "Inlet stream molar entropy";
  Real xvapin(unit = "-", min = 0, max = 1, start = xvapg) "Inlet stream vapor phase mole fraction"; 
  
  Real Tdel(unit = "K") "Temperature increase";
  Real Pdel(unit = "Pa") "Pressure drop"; 
 
  Real Fout(unit = "mol/s", min = 0, start = Fg) "outlet stream molar flow rate";
  Real Pout(unit = "Pa", min = 0, start = Pg) "Outlet stream pressure";
  Real Tout(unit = "K", min = 0, start = Tg) "Outlet stream temperature";
  Real Hout(unit = "kJ/kmol",start=Htotg) "Outlet stream molar enthalpy";
  Real Sout(unit = "kJ/[kmol.K]")  "Outlet stream molar entropy";
  Real x_c[Nc](each unit = "-", each min = 0, each max = 1,  start = xg) "Component mole fraction";
  Real xvapout(unit = "-", min = 0, max = 1, start = xvapg) "Outlet stream vapor phase mole fraction";

  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). Upstream leaves this model one
     degree of freedom short and expects the flowsheet to close it by hand:

         B1.Pdel = 101325;

     The selector below offers the same closures as parameters instead, so the
     choice appears in the block's own dialog rather than having to be known in
     advance and typed elsewhere.

     The default is FlowsheetEquation, under which the if-equation at the end of
     the equation section contributes NOTHING and the model behaves exactly as it
     did before -- which is what keeps the shipped examples, and any existing
     user flowsheet, working. Differing equation counts per branch are legal
     because `spec` is a parameter. Names are fully qualified rather than
     imported because the `enable` expressions are read by OMEdit's dialog
     builder, not by the compiler. */
  parameter Simulator.Files.Types.ValveSpec spec = Simulator.Files.Types.ValveSpec.FlowsheetEquation
    "Which quantity fixes the pressure" annotation(
    Dialog(tab = "Valve Specifications", group = "Calculation Mode"));
  parameter Real Pout_spec(unit = "Pa", displayUnit = "bar") = 101325 "Outlet pressure" annotation(
    Dialog(tab = "Valve Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.ValveSpec.OutletPressure));
  parameter Real Pdel_spec(unit = "Pa", displayUnit = "bar") = 1e5 "Pressure drop" annotation(
    Dialog(tab = "Valve Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.ValveSpec.PressureDrop));
  //========================================================================================
  //========================================================================================
  Simulator.Files.Interfaces.matConn In(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Files.Interfaces.matConn Out(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  //========================================================================================
  extends GuessModels.InitialGuess;
equation
//connector equations
  In.P = Pin;
  In.T = Tin;
  In.F = Fin;
  In.H = Hin;
  In.S = Sin;
  In.x_pc[1, :] = x_c[:];
  In.xvap = xvapin;
  Out.P = Pout;
  Out.T = Tout;
  Out.F = Fout;
  Out.H = Hout;
  Out.S = Sout;
  Out.x_pc[1, :] = x_c[:];
  Out.xvap = xvapout;
//=============================================================================================
  Fin = Fout;
//material balance
  Hin = Hout;
//energy balance
  Pin - Pdel = Pout;
//pressure calculation
  Tin + Tdel = Tout;
//temperature calculation
//===============================================================================
//Duty specification -- closes the model's one remaining degree of freedom.
//NOT IN UPSTREAM v1.0. No `else` branch: under the default FlowsheetEquation
//this emits no equation at all, leaving the DOF for the flowsheet to close.
  if spec == Simulator.Files.Types.ValveSpec.OutletPressure then
    Pout = Pout_spec;
  elseif spec == Simulator.Files.Types.ValveSpec.PressureDrop then
    Pdel = Pdel_spec;
  end if;
  annotation(
    Documentation(info = "<html><head></head><body><!--StartFragment--><span style=\"font-size: 12px;\">The&nbsp;<b>Valve</b>&nbsp;is used to simulate the pressure manipulation process of a material stream.</span><div><br></div><div><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px; orphans: 2; widows: 2;\">The valve model have t</span><span style=\"font-size: 13px; font-family: Arial, Helvetica, sans-serif; orphans: 2; widows: 2;\">wo Material Streams connection ports as:</span></div><div><div style=\"orphans: 2; widows: 2;\"><ol><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">feed stream</span></li><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">outlet stream</span></li></ol></div><div style=\"font-size: 12px;\"><br></div><div style=\"font-size: 12px;\">To simulate a valve, one of the following variables must be provided:</div><div style=\"font-size: 12px;\"><div><ol><li>Outlet Pressure (<b>Pout</b>)</li><li>Pressure Drop (<b>Pdel</b>)</li></ol></div><div><div><div><div>These variables are declared of type&nbsp;<i>Real.</i></div><div>During simulation, value of one of these variables need to be defined in the equation section.</div></div><div><br></div><div><br></div></div><div>For detailed explanation on how to use this model to simulate a Valve, go to&nbsp;<a href=\"modelica://Simulator.Examples.Valve\">Valve Example</a>.</div></div></div></div><!--EndFragment--><div><br></div><hr><div><br></div><div><b>Calculation mode (added; not in upstream v1.0)</b></div><div><br></div><div>The duty may now be specified on the block itself instead of by an equation in the flowsheet. Under <b>Valve Specifications &rarr; Calculation Mode</b>, set <b>spec</b> to one of:</div><div><ol><li><b>OutletPressure</b> &mdash; let the stream down to this pressure (<b>Pout_spec</b>)</li><li><b>PressureDrop</b> &mdash; drop this much from the inlet pressure (<b>Pdel_spec</b>)</li></ol></div><div>Only the field belonging to the selected mode is enabled; the others are greyed out. Pressures may be entered in bar and duties in kW &mdash; the model stores Pa and W.</div><div><br></div><div>The default is <b>FlowsheetEquation</b>, under which the model contributes no closing equation and the flowsheet must supply one, exactly as described above (<code>B1.Pdel = 101325;</code>). That is why existing models are unaffected.</div><div><br></div><div><b>Use one route or the other, not both</b> &mdash; selecting a mode <i>and</i> writing a duty equation in the flowsheet over-determines the model.</div></body></html>"));
    
    end Valve;
