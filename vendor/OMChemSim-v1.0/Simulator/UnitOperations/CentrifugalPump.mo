within Simulator.UnitOperations;

model CentrifugalPump "Model of a centrifugal pump to provide energy to liquid stream in form of pressure"
  //===========================================================================
  //Header files and Parameters
  extends Simulator.Files.Icons.CentrifugalPump;
  parameter Real Eff(unit = "-") "Efficiency" annotation(
    Dialog(tab = "Pump Specifications", group = "Calculation Parameters"));

  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). Upstream leaves the pump one
     degree of freedom short and expects the flowsheet to close it by hand:

         B1.Pdel = 101325;

     The selector below offers the same three closures as parameters instead, so
     the choice appears in the block's own dialog rather than having to be known
     in advance and typed elsewhere.

     The default is FlowsheetEquation, under which the if-equation contributes
     NOTHING and the model behaves exactly as it did before. That is what keeps
     Examples.Pump -- and any existing user flowsheet -- working: had the default
     emitted an equation, every model that already specifies the duty in its
     equation section would have become over-determined.

     Differing equation counts per branch are legal here because `spec` is a
     parameter, so the branch is resolved before balance checking. The names are
     fully qualified rather than imported because the `enable` expressions are
     read by OMEdit's dialog builder, not by the compiler. */
  parameter Simulator.Files.Types.PumpSpec spec = Simulator.Files.Types.PumpSpec.FlowsheetEquation
    "Which quantity fixes the pump duty" annotation(
    Dialog(tab = "Pump Specifications", group = "Calculation Mode"));
  parameter Real Pout_spec(unit = "Pa", displayUnit = "bar") = 2e5 "Outlet pressure" annotation(
    Dialog(tab = "Pump Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.PumpSpec.OutletPressure));
  parameter Real Pdel_spec(unit = "Pa", displayUnit = "bar") = 1e5 "Pressure increase" annotation(
    Dialog(tab = "Pump Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.PumpSpec.PressureIncrease));
  parameter Real Q_spec(unit = "W", displayUnit = "kW") = 1e3 "Shaft power required" annotation(
    Dialog(tab = "Pump Specifications", group = "Calculation Mode",
      enable = spec == Simulator.Files.Types.PumpSpec.PowerRequired));
  //===========================================================================
  //Model Variables
  Real Pin(unit = "Pa", min = 0, start = Pg) "Inlet stream pressure";
  Real Tin(unit = "K", min = 0, start = Tg) "Inlet stream temperature";
  Real Hin(unit = "kJ/kmol",start=Htotg) "Inlet stream molar enthalpy";
  Real Fin(unit = "mol/s", min = 0, start = Fg) "Inlet stream molar flow";
  Real xin_c[Nc](each unit = "-", each min = 0, each max = 1, start=xg) "Inlet stream components molar fraction";
  Real Tdel(unit = "K") "Temperature increase";
  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). Pdel carried unit = "K",
     copied from the Tdel line above. Nothing depended on it numerically, but
     it made checkModel report "Pin + Pdel = Pout" as INCONSISTENT and hid the
     two genuine unit faults below in the noise. */
  Real Pdel(unit = "Pa") "Pressure increase";
  Real Q(unit = "W") "Power required";
  /* NOT IN UPSTREAM v1.0. Both densities were labelled kmol/m3, but
     ThermodynamicFunctions.Dens multiplies the Chemsep coefficients by 1000
     and so returns mol/m3 -- benzene/toluene at 300 K comes back as 10179.5,
     not 10.18. The arithmetic below was always right; only the label was
     wrong, and it is what makes Pdel/rho land in J/mol to match Hin. */
  Real rho_c[Nc](each unit = "mol/m3", each min = 0) "Component molar density";
  Real rho(unit = "mol/m3", min = 0) "Mixture molar density";
  Real MWavg(unit = "g/mol", min = 0) "Mixture average molecular weight";
  Real rhoMass(unit = "kg/m3", min = 0) "Mixture mass density";
  Real Pvap(unit = "Pa", min = 0, start = Pg) "Vapor pressure of mixture at inlet temperature";
  Real NPSH(unit = "m") "Net Positive Suction Head available";
  Real Pout(unit = "Pa", min = 0, start = Pg) "Outlet stream pressure";
  Real Tout(unit = "K", min = 0, start = Tg) "Outlet stream temperature";
  Real Hout(unit = "kJ/kmol",start=Htotg) "Outlet stream molar enthalpy";
  Real Fout(unit = "mol/s", min = 0, start = Fg) "Outlet stream molar flow";
  Real xout_c[Nc](each unit = "-", each min = 0, each max = 1, start=xg) "Outlet stream molar fraction";
  //============================================================================
  //Instantiation of Connectors
  Simulator.Files.Interfaces.matConn In(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {-100, -2}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-100, 16}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Files.Interfaces.matConn Out(Nc = Nc) annotation(
    Placement(visible = true, transformation(origin = {102, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {100, 100}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Simulator.Files.Interfaces.enConn En annotation(
    Placement(visible = true, transformation(origin = {2, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {0, -70}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

  extends GuessModels.InitialGuess;
equation
//============================================================================
//Connector equation
  In.P = Pin;
  In.T = Tin;
  In.F = Fin;
  In.H = Hin;
  In.x_pc[1, :] = xin_c[:];
  Out.P = Pout;
  Out.T = Tout;
  Out.F = Fout;
  Out.H = Hout;
  Out.x_pc[1, :] = xout_c[:];
  En.Q = Q;
//=============================================================================
//Pump equations
  Fin = Fout;
  xin_c = xout_c;
  Pin + Pdel = Pout;
  Tin + Tdel = Tout;
//=============================================================================
//Calculation of Density
  for i in 1:Nc loop
    rho_c[i] = Simulator.Files.ThermodynamicFunctions.Dens(C[i].LiqDen, C[i].Tc, Tin, Pin);
  end for;
  rho = 1 / sum(xin_c ./ rho_c);
  MWavg = sum(xin_c .* C[:].MW);
  rhoMass = rho * MWavg / 1000;
//==============================================================================
//Energy Balance and NPSH Calculation
  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). Upstream put the IDEAL head
     Pdel/rho into the fluid and then divided only the shaft power by Eff:

         Hout = Hin + Pdel/rho;   Q = Fin*(Hout - Hin)/Eff;

     so the pump drew Fin*Pdel/(rho*Eff) at the shaft while the stream gained
     Fin*Pdel/rho, and the difference simply vanished. For an adiabatic pump
     that difference is friction, and it heats the fluid. On the shipped
     Examples.Pump case (100 mol/s benzene/toluene, 1 atm rise, Eff = 0.75)
     332 W of a 1327 W shaft duty went missing and the outlet came out at
     300.067 K instead of 300.090 K -- the temperature rise was understated by
     exactly (1 - Eff), for every pump, always.

     The actual enthalpy rise is the ideal head divided by the efficiency; the
     shaft power is then just the enthalpy rise, with no second division. */
  Hout = Hin + Pdel / (rho * Eff);
  Q = Fin * (Hout - Hin);
  /* NOT IN UPSTREAM v1.0. NPSH is declared in metres but was computed as
     (Pin - Pvap)/rho with rho molar, i.e. J/mol -- checkModel flags the
     equation as INCONSISTENT unprompted. NPSH available is a head:

         NPSHa = (Pin - Pvap) / (rho_mass * g)

     The old form was not even a constant factor out, since the discrepancy is
     rho_mass*g/rho_molar and so scales with molecular weight: the example
     reported 9.079 where the head is 10.87 m. */
  NPSH = (Pin - Pvap) / (rhoMass * Modelica.Constants.g_n);
//===============================================================================
//Vapor Pressure of mixture at Inlet Temperature
  /* NOT IN UPSTREAM v1.0. Evaluated at Tout upstream. Cavitation is a
     suction-side phenomenon, so the vapour pressure that matters is the one at
     the pump inlet. Using Tout also tied NPSH to the outlet temperature, which
     this model cannot compute on its own (it carries no H-T relation and
     closes only through the downstream material stream), so NPSH was not
     available until an outlet stream was attached. */
  Pvap = sum(xin_c .* exp(C[:].VP[2] + C[:].VP[3] / Tin + C[:].VP[4] * log(Tin) + C[:].VP[5] .* Tin .^ C[:].VP[6]));
//===============================================================================
//Duty specification -- closes the model's one remaining degree of freedom.
//NOT IN UPSTREAM v1.0. No `else` branch: under the default FlowsheetEquation
//this emits no equation at all, leaving the DOF for the flowsheet to close.
  if spec == Simulator.Files.Types.PumpSpec.OutletPressure then
    Pout = Pout_spec;
  elseif spec == Simulator.Files.Types.PumpSpec.PressureIncrease then
    Pdel = Pdel_spec;
  elseif spec == Simulator.Files.Types.PumpSpec.PowerRequired then
    Q = Q_spec;
  end if;
  annotation(
    Documentation(info = "<html><head></head><body><!--StartFragment--><div>The&nbsp;<b>Centrifugal Pump</b>&nbsp;is generally used to provide energy to a liquid material stream. The energy supplied is in form of pressure.</div><div><br></div><div><div><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px; orphans: 2; widows: 2;\">The centrifugal pump model have following connection ports:</span></div><div><div style=\"orphans: 2; widows: 2;\"><ol><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">Two Material Streams:</span></font></li><ul><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">feed stream</span></li><li><span style=\"font-family: Arial, Helvetica, sans-serif; font-size: 13px;\">outlet stream</span></li></ul><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">One Energy Stream:</span></font></li><ul><li><font face=\"Arial, Helvetica, sans-serif\"><span style=\"font-size: 13px;\">power required</span></font></li></ul></ol></div></div></div><div><br></div><div><br></div>To simulate a centrifugal pump, Efficiency (<b>Eff</b>) of the pump should be provided as calculation parameter. T<span style=\"font-size: 12px;\">he variable&nbsp;<b>Eff</b>&nbsp;is defined as of type&nbsp;</span><i style=\"font-size: 12px;\">parameter Real.<br></i>During simulation, its value can specified directly under <b>Pump&nbsp;Specifications</b>&nbsp;by double clicking on the pump model instance.<div><br></div><div><br></div><div>Additionally the pump's duty must be specified, in one of two ways.<div><br></div><div><b>1. From the block's own dialog (recommended).</b> Under <b>Pump Specifications &rarr; Calculation Mode</b>, set <b>spec</b> to one of:</div><div><ol><li><b>OutletPressure</b> &mdash; the pump raises the stream to <b>Pout_spec</b></li><li><b>PressureIncrease</b> &mdash; the pump adds <b>Pdel_spec</b> to the inlet pressure</li><li><b>PowerRequired</b> &mdash; the shaft delivers <b>Q_spec</b>, and the pressure rise follows</li></ol></div><div>Only the field belonging to the selected mode is enabled; the others are greyed out. Pressures may be entered in bar and power in kW &mdash; the model stores Pa and W.</div><div><br></div><div><b>2. From an equation in the flowsheet</b> (the original style). Leave <b>spec</b> at its default, <b>FlowsheetEquation</b>, and assign one of the variables <b>Pout</b>, <b>Pdel</b> or <b>Q</b> in the flowsheet's equation section:</div><div><br></div><div><code>&nbsp;&nbsp;B1.Pdel = 101325;</code></div><div><br></div><div>In this mode the pump contributes no closing equation of its own, which is why it is the default: it is what every model written against the original library already expects.</div><div><br></div><div><b>Use one route or the other, not both</b> &mdash; selecting a mode <i>and</i> writing a flowsheet equation over-determines the model.</div><div><br></div></div><div><br></div><div><span style=\"font-size: 12px;\">For detailed explanation on how to use this model to simulate a Centrifugal Pump, go to&nbsp;</span><a href=\"modelica://Simulator.Examples.Pump\" style=\"font-size: 12px;\">Centrifugal Pump Example</a><span style=\"font-size: 12px;\">.</span></div></div><!--EndFragment--></body></html>"));
    
end CentrifugalPump;
