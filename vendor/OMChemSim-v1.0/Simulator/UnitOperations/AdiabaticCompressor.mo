within Simulator.UnitOperations;

model AdiabaticCompressor "Model of an adiabatic compressor to provide energy to vapor stream in form of pressure"
  extends Simulator.Files.Icons.AdiabaticCompressor;
  
  extends Simulator.Files.Models.Flash;
  
//====================================================================================
  Real Fin(unit = "mol/s", min = 0, start = Fg) "Inlet stream molar flow rate";
  Real Pin(unit = "Pa", min = 0, start = Pg) "Inlet stream pressure"; 
  Real Tin(unit = "K", min = 0, start = Tg) "Inlet stream temperature";
  Real Hin(unit = "kJ/kmol",start=Htotg) "Inlet stream molar enthalpy";
  Real Sin(unit = "kJ/[kmol/K]") "Inlet stream molar entropy";
  Real xvapin(unit = "-", min = 0, max = 1, start = xvapg) "Inlet stream vapor phase mol fraction";   
  
  Real Fout(min = 0, start = Fg) "Outlet stream molar flow rate";
  Real Q(unit = "W") "Power required";
  Real Pdel(unit = "Pa") "Pressure increase"; 
  Real Tdel(unit = "K") "Temperature increase"; 

  Real Pout(unit = "Pa", min = 0, start = Pg) "Outlet stream pressure";
  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). Tout carried unit = "Pa",
     copied from the Pout line above it. Harmless numerically, but checkModel
     reported "Tin + Tdel = Tout" as INCONSISTENT -- the same fault, and the
     same fix, as Pdel(unit = "K") in CentrifugalPump. */
  Real Tout(unit = "K", min = 0, start = Tg) "Outlet stream temperature";
  Real Hout(unit = "kJ/kmol",start=Htotg) "Outlet stream molar enthalpy";
  Real Sout(unit = "kJ/[kmol.K]") "Outlet stream molar entropy";
  Real xvapout(unit = "-", min = 0, max = 1, start = xvapg) "Outlet stream vapor phase mole fraction";
  Real x_c[Nc](each unit = "-", each min = 0, each max = 1,start=xg) "Component mole fraction";
 
  parameter Real Eff(unit = "-") "Efficiency" annotation(
    Dialog(tab = "Compressor Specifications", group = "Calculation Parameters"));

  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). Upstream leaves this model one
     degree of freedom short and expects the flowsheet to close it by hand:

         B1.Pdel = 10000;

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
  parameter Simulator.Files.Types.CompressorSpec spec = Simulator.Files.Types.CompressorSpec.FlowsheetEquation
    "Which quantity fixes the duty" annotation(
    Dialog(tab = "Compressor Specifications", group = "Calculation Mode"));
  parameter Real Pout_spec(unit = "Pa", displayUnit = "bar") = 5e5 "Outlet pressure" annotation(
    Dialog(tab = "Compressor Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.CompressorSpec.OutletPressure));
  parameter Real Pdel_spec(unit = "Pa", displayUnit = "bar") = 1e4 "Pressure increase" annotation(
    Dialog(tab = "Compressor Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.CompressorSpec.PressureIncrease));
  parameter Real Q_spec(unit = "W", displayUnit = "kW") = 1e4 "Shaft power required" annotation(
    Dialog(tab = "Compressor Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.CompressorSpec.PowerRequired));

//========================================================================================
  Simulator.Files.Interfaces.matConn In(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Files.Interfaces.matConn Out(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Files.Interfaces.enConn En annotation(
    Placement(visible = true, transformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {0, -66}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
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
  Hout = Hin + (H_p[1] - Hin) / Eff;
  Q = Fin * (H_p[1] - Hin) / Eff;
//energy balance
  Pin + Pdel = Pout;
//pressure calculation
  Tin + Tdel = Tout;
//temperature calculation
//=========================================================================
//ideal flash
  Fin = F_p[1];
  Pout = P;
  Sin = S_p[1];
  x_c[:] = x_pc[1, :];
//===============================================================================
//Duty specification -- closes the model's one remaining degree of freedom.
//NOT IN UPSTREAM v1.0. No `else` branch: under the default FlowsheetEquation
//this emits no equation at all, leaving the DOF for the flowsheet to close.
  if spec == Simulator.Files.Types.CompressorSpec.OutletPressure then
    Pout = Pout_spec;
  elseif spec == Simulator.Files.Types.CompressorSpec.PressureIncrease then
    Pdel = Pdel_spec;
  elseif spec == Simulator.Files.Types.CompressorSpec.PowerRequired then
    Q = Q_spec;
  end if;
annotation(
    Documentation(info = "<html><head></head><body><div style=\"font-size: 12px;\">The <b>Adiabatic Compressor</b> is generally used to provide energy to a vapor material stream. The energy supplied is in form of pressure.</div><div style=\"font-size: 12px;\"><div><br></div><div><div><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px; orphans: 2; widows: 2;\">The adiabatic compressor model have following connection ports:</span></div><div><div style=\"orphans: 2; widows: 2;\"><ol><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">Two Material Streams:</span></font></li><ul><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">feed stream</span></li><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">outlet stream</span></li></ul><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">One Energy Stream:</span></font></li><ul><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">power required</span></font></li></ul></ol></div></div></div><div><br></div><div><br></div>To simulate an adiabatic compressor, Efficiency (<b>Eff</b>) of the compressor should be provided as calculation parameter. The variable&nbsp;<b>Eff</b>&nbsp;is defined as of type&nbsp;<i>parameter Real.</i>&nbsp;</div><div style=\"font-size: 12px;\"><span style=\"font-size: medium;\">During simulation, its value can specified directly under&nbsp;</span><b style=\"font-size: medium;\">Compressor Specifications</b><span style=\"font-size: medium;\">&nbsp;by double clicking on the compressor model instance.</span><br><div><br></div><div><br></div><div>Additionally one of the following input variables must be defined:<div><ol><li>Outlet Pressure (<b>Pout</b>)</li><li>Pressure Increase (<b>Pdel</b>)</li><li>Power Required (<b>Q</b>)</li></ol><div>These variables are declared of type&nbsp;<i>Real.</i></div><div>During simulation, value of one of these variables need to be defined in the equation section.</div></div><div><br></div><div>For detailed explanation on how to use this model to simulate an Adiabatic Compressor, go to&nbsp;<a href=\"modelica://Simulator.Examples.Compressor\">Adiabatic Compressor Example</a>.</div></div></div><div><br></div><hr><div><br></div><div><b>Calculation mode (added; not in upstream v1.0)</b></div><div><br></div><div>The duty may now be specified on the block itself instead of by an equation in the flowsheet. Under <b>Compressor Specifications &rarr; Calculation Mode</b>, set <b>spec</b> to one of:</div><div><ol><li><b>OutletPressure</b> &mdash; raise the stream to this pressure (<b>Pout_spec</b>)</li><li><b>PressureIncrease</b> &mdash; add this much to the inlet pressure (<b>Pdel_spec</b>)</li><li><b>PowerRequired</b> &mdash; deliver this shaft power; the pressure rise follows (<b>Q_spec</b>)</li></ol></div><div>Only the field belonging to the selected mode is enabled; the others are greyed out. Pressures may be entered in bar and duties in kW &mdash; the model stores Pa and W.</div><div><br></div><div>The default is <b>FlowsheetEquation</b>, under which the model contributes no closing equation and the flowsheet must supply one, exactly as described above (<code>B1.Pdel = 10000;</code>). That is why existing models are unaffected.</div><div><br></div><div><b>Use one route or the other, not both</b> &mdash; selecting a mode <i>and</i> writing a duty equation in the flowsheet over-determines the model.</div></body></html>"));
    end AdiabaticCompressor;
