within Simulator.UnitOperations;

model Cooler "Model of a cooler to heat a material stream"
  extends Simulator.Files.Icons.Cooler; 
  
  //====================================================================================
  Real Fin(unit = "mol/s", min = 0, start = Fg) "Inlet stream molar flow rate";
  Real Pin(unit = "Pa", min = 0, start =Pg) "Inlet stream pressure";
  Real Tin(unit = "K", min = 0, start = Tg) "Inlet stream temperature";
  Real Hin(unit = "kJ/kmol") "Inlet stream molar enthalpy";
  Real Sin(unit = "kJ/[kmol.K]") "Inlet stream molar entropy";
  Real xvapin(unit = "-", min = 0, max = 1, start = xvapg) "Inlet stream vapor phase mole fraction";
  
  Real Q(unit = "W") "Heat removed";
  Real Tdel(unit = "K") "Temperature drop";
   
  Real Fout(unit = "mol/s", min = 0, start = Fg) "Outlet stream molar flow rate";
  Real Pout(unit = "Pa", min = 0, start = Pg) "Outlet stream pressure";
  Real Tout(unit = "K", min = 0, start = Tg) "Outlet stream temperature";
  Real xvapout(unit = "-", min = 0, max = 1, start = xvapg) "Outlet stream vapor phase mole fraction";
  Real Hout(unit = "kJ/kmol") "Outlet stream molar enthalpy";
  Real Sout(unit = "kJ/[kmol.K]") "Outlet stream molar entropy"; 
  Real x_c[Nc](each unit = "-", each min = 0, each max = 1, start=xg) "Component mole fraction";
  //========================================================================================
  parameter Real Pdel(unit = "Pa") "Pressure drop" annotation(
    Dialog(tab = "Cooler Specifications", group = "Calculation Parameters"));
  parameter Real Eff(unit = "-") "Efficiency" annotation(
    Dialog(tab = "Cooler Specifications", group = "Calculation Parameters"));

  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). Upstream leaves this model one
     degree of freedom short and expects the flowsheet to close it by hand:

         B1.Q = 200000;

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
  parameter Simulator.Files.Types.CoolerSpec spec = Simulator.Files.Types.CoolerSpec.FlowsheetEquation
    "Which quantity fixes the duty" annotation(
    Dialog(tab = "Cooler Specifications", group = "Calculation Mode"));
  parameter Real Tout_spec(unit = "K") = 298.15 "Outlet temperature" annotation(
    Dialog(tab = "Cooler Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.CoolerSpec.OutletTemperature));
  parameter Real Tdel_spec(unit = "K") = 10 "Temperature drop" annotation(
    Dialog(tab = "Cooler Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.CoolerSpec.TemperatureDrop));
  parameter Real Q_spec(unit = "W", displayUnit = "kW") = 1e5 "Heat removed" annotation(
    Dialog(tab = "Cooler Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.CoolerSpec.HeatRemoved));
  parameter Real xvapout_spec(unit = "-", min = 0, max = 1) = 0.5 "Outlet vapour fraction" annotation(
    Dialog(tab = "Cooler Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.CoolerSpec.OutletVaporFraction));

//========================================================================================
  Simulator.Files.Interfaces.matConn In(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Files.Interfaces.matConn Out(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Files.Interfaces.enConn En annotation(
    Placement(visible = true, transformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
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
  En.Q = Q;
//=============================================================================================
  Fin = Fout;
//material balance
  Hin - Eff * Q / Fin = Hout;
//energy balance
  Pin - Pdel = Pout;
//pressure calculation
  Tin - Tdel = Tout;
//temperature calculation
//===============================================================================
//Duty specification -- closes the model's one remaining degree of freedom.
//NOT IN UPSTREAM v1.0. No `else` branch: under the default FlowsheetEquation
//this emits no equation at all, leaving the DOF for the flowsheet to close.
  if spec == Simulator.Files.Types.CoolerSpec.OutletTemperature then
    Tout = Tout_spec;
  elseif spec == Simulator.Files.Types.CoolerSpec.TemperatureDrop then
    Tdel = Tdel_spec;
  elseif spec == Simulator.Files.Types.CoolerSpec.HeatRemoved then
    Q = Q_spec;
  elseif spec == Simulator.Files.Types.CoolerSpec.OutletVaporFraction then
    xvapout = xvapout_spec;
  end if;
  annotation(
    Documentation(info = "<html><head></head><body><span style=\"font-size: 12px;\">The <b>Cooler</b> is used to simulate the cooling process of a material stream.</span><div><br></div><div><div><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px; orphans: 2; widows: 2;\">The cooler model have following connection ports:</span></div><div><div style=\"orphans: 2; widows: 2;\"><ol><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">Two Material Streams:</span></font></li><ul><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">feed stream</span></li><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">outlet stream</span></li></ul><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">One Energy Stream:</span></font></li><ul><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">heat removed</span></li></ul></ol></div></div><div style=\"font-size: 12px;\"><br></div><div style=\"font-size: 12px;\">Following calculation parameters must be provided to the cooler:</div><div style=\"font-size: 12px;\"><ol><li>Pressure Drop (<b>Pdel</b>)</li><li>Efficiency (<b>Eff</b>)</li></ol><div><div>The above variables have been declared of type&nbsp;<i>parameter Real.&nbsp;</i></div><div>During simulation, their values can specified directly under&nbsp;<b>Cooler Specifications</b>&nbsp;by double clicking on the cooler model instance.</div></div><div><br></div><div><br></div><div>In addition to the above parameters, any one additional variable from the below list must be provided for the model to simulate successfully:</div><div><ol><li>Outlet Temperature (<b>Tout</b>)</li><li>Temperature Drop (<b>Tdel</b>)</li><li>Heat Removed (<b>Q</b>)</li><li>Outlet Stream Vapor Phase Mole Fraction (<b>xvapout</b>)</li></ol><div><div>These variables are declared of type&nbsp;<i>Real.</i></div><div>During simulation, value of one of these variables need to be defined in the equation section.</div></div><div><br></div><div><br></div></div><div>For detailed explanation on how to use this model to simulate a Cooler, go to <a href=\"modelica://Simulator.Examples.Cooler\">Cooler Example</a></div></div></div><div><br></div><hr><div><br></div><div><b>Calculation mode (added; not in upstream v1.0)</b></div><div><br></div><div>The duty may now be specified on the block itself instead of by an equation in the flowsheet. Under <b>Cooler Specifications &rarr; Calculation Mode</b>, set <b>spec</b> to one of:</div><div><ol><li><b>OutletTemperature</b> &mdash; cool until the stream reaches this temperature (<b>Tout_spec</b>)</li><li><b>TemperatureDrop</b> &mdash; lower the stream by this many kelvin (<b>Tdel_spec</b>)</li><li><b>HeatRemoved</b> &mdash; remove this duty; the temperature drop follows (<b>Q_spec</b>)</li><li><b>OutletVaporFraction</b> &mdash; cool until the outlet reaches this vapour fraction (<b>xvapout_spec</b>)</li></ol></div><div>Only the field belonging to the selected mode is enabled; the others are greyed out. Pressures may be entered in bar and duties in kW &mdash; the model stores Pa and W.</div><div><br></div><div>The default is <b>FlowsheetEquation</b>, under which the model contributes no closing equation and the flowsheet must supply one, exactly as described above (<code>B1.Q = 200000;</code>). That is why existing models are unaffected.</div><div><br></div><div><b>Use one route or the other, not both</b> &mdash; selecting a mode <i>and</i> writing a duty equation in the flowsheet over-determines the model.</div></body></html>"));
    
    end Cooler;
