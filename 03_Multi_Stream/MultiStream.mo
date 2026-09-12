package MultiStream "Two material streams, two property methods, in one model"
  extends Modelica.Icons.Package;

  /* --------------------------------------------------------------------------
     Everything a stream needs comes from one of two places, and the point of
     this package is that a single model can draw on both at once:

       * OMChemSim (vendor/OMChemSim-v1.0) supplies MaterialStream and the
         property packages -- Raoult, NRTL, UNIQUAC, UNIFAC, Peng-Robinson,
         Grayson-Streed -- for MULTICOMPONENT mixtures. Composition is the whole
         point of it: VLE, K-values, bubble and dew pressures.

       * The Modelica Standard Library supplies Modelica.Media, whose
         Water.StandardWater is the IAPWS-IF97 steam tables. It is a
         single-substance medium, so it has no composition at all -- what it has
         instead is reference-quality water properties over the full range a
         steam system uses.

     Neither one subsumes the other. Peng-Robinson gives poor water properties;
     the steam tables cannot flash a hydrocarbon mixture. A real flowsheet has
     both kinds of stream in it, so this package puts one of each into a single
     model and lets you plot them side by side.

     Load order matters -- see 03_Multi_Stream/README.md.
     -------------------------------------------------------------------------- */

  package Composites "Material stream joined to a property package"
    extends Modelica.Icons.BasesPackage;

    /* A MaterialStream on its own is incomplete: it consumes K-values and
       residual properties that a property package has to supply. Mix the two
       here, leaving Nc and C unmodified, and specify the components at the
       point of use -- MS_PR S1(Nc = 3, C = C). Modifying Nc/C on only one
       extends clause is an error; see MODELLING_GUIDE.md section 2. */

    model MS_PR "Material stream, Peng-Robinson equation of state"
      extends Simulator.Streams.MaterialStream;
      extends Simulator.Files.ThermodynamicPackages.PengRobinson;
      annotation(
        Documentation(info = "<html><body>A cubic equation of state applied to both phases. The natural choice for hydrocarbons and light gases, where the liquid is non-polar and the vapour is far from ideal.</body></html>"));
    end MS_PR;

    model MS_Raoult "Material stream, Raoult's law"
      extends Simulator.Streams.MaterialStream;
      extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;
      annotation(
        Documentation(info = "<html><body>Ideal liquid solution, ideal vapour. Kept here as the reference case to plot the Peng-Robinson stream against.</body></html>"));
    end MS_Raoult;
  end Composites;

  model SteamStream "Pure water stream evaluated on the IAPWS-IF97 steam tables"

    /* Deliberately shaped like an OMChemSim stream: P, T and F are declared but
       left unsolved, so the enclosing model specifies them the same way it
       specifies HC.P, HC.T and HC.F_p[1]. Everything else is computed. */

    replaceable package Medium = Modelica.Media.Water.StandardWater
      constrainedby Modelica.Media.Interfaces.PartialTwoPhaseMedium
      "Water medium -- StandardWater is IF97"
      annotation(choicesAllMatching = true);

    constant Real MW(unit = "kg/kmol") = 18.01528 "Molar mass of water";

    //--- Specifications: supplied by the enclosing model -----------------------
    Modelica.Units.SI.AbsolutePressure P(start = 101325, min = 611.657) "Pressure -- SPECIFY";
    Modelica.Units.SI.Temperature T(start = 373.15, min = 273.16) "Temperature -- SPECIFY";
    Real F(unit = "mol/s", min = 0, start = 100) "Molar flow -- SPECIFY";

    //--- Computed -------------------------------------------------------------
    Medium.ThermodynamicState state "IF97 state at (P, T)";
    Real Fm(unit = "kg/s") "Mass flow";
    Real Fv(unit = "m3/s") "Volumetric flow at stream conditions";

    Real h(unit = "J/kg") "Specific enthalpy, IF97 reference";
    Real s(unit = "J/(kg.K)") "Specific entropy, IF97 reference";
    Real d(unit = "kg/m3") "Density";
    Real cp(unit = "J/(kg.K)") "Specific heat at constant pressure";
    Real u(unit = "J/kg") "Specific internal energy";

    Real H_molar(unit = "kJ/kmol") "Molar enthalpy, for comparison with an OMChemSim stream";
    Real S_molar(unit = "kJ/(kmol.K)") "Molar entropy, for comparison with an OMChemSim stream";

    //--- Where the stream sits relative to saturation -------------------------
    Modelica.Units.SI.Temperature Tsat "Saturation temperature at P";
    Modelica.Units.SI.AbsolutePressure Pvap "Vapour pressure at T";
    Real dTsup(unit = "K") "Degrees of superheat; negative means subcooled liquid";
    Real hf(unit = "J/kg") "Saturated liquid enthalpy at P";
    Real hg(unit = "J/kg") "Saturated vapour enthalpy at P";
    Real hfg(unit = "J/kg") "Latent heat of vaporisation at P";
    Integer phase "1 = subcooled liquid, 3 = superheated vapour (OMChemSim phase index)";

  protected
    Medium.SaturationProperties sat "Saturation state at P";

  equation
    /* setState_pT resolves the IF97 region from T against Tsat(P): below it the
       state is region 1 (compressed liquid), above it region 2 (superheated
       vapour). Exactly on the saturation line the pair (P, T) does not identify
       a state at all -- pressure and temperature are not independent there --
       so a two-phase steam stream has to be specified as (P, h) or (P, x)
       instead. Keep sweep points off the saturation line, or expect the
       properties to step as the point crosses it. */
    state = Medium.setState_pT(P, T);
    sat = Medium.setSat_p(P);

    h = Medium.specificEnthalpy(state);
    s = Medium.specificEntropy(state);
    d = Medium.density(state);
    cp = Medium.specificHeatCapacityCp(state);
    u = h - P / d;

    Fm = F * MW / 1000;
    Fv = Fm / d;

    H_molar = h * MW / 1000;
    S_molar = s * MW / 1000;

    Tsat = Medium.saturationTemperature(P);
    Pvap = Medium.saturationPressure(T);
    dTsup = T - Tsat;
    hf = Medium.bubbleEnthalpy(sat);
    hg = Medium.dewEnthalpy(sat);
    hfg = hg - hf;
    phase = if T > Tsat then 3 else 1;

    annotation(
      Icon(graphics = {
        Rectangle(fillColor = {214, 234, 248}, fillPattern = FillPattern.Solid,
                  extent = {{-100, -40}, {100, 40}}),
        Polygon(fillColor = {41, 128, 185}, fillPattern = FillPattern.Solid,
                points = {{40, 30}, {100, 0}, {40, -30}, {40, 30}}),
        Text(extent = {{-90, 20}, {30, -20}}, textString = "H2O")}),
      Documentation(info = "<html><body><p>A pure-water stream whose properties come from the IAPWS-IF97 steam tables through <code>Modelica.Media.Water.StandardWater</code>, specified the same way an OMChemSim stream is: give it <b>P</b>, <b>T</b> and <b>F</b> from the enclosing model.</p><p><b>Reference states differ.</b> IF97 sets enthalpy and entropy to zero for saturated liquid at the triple point. OMChemSim builds enthalpy from standard enthalpies of formation. <code>H_molar</code> is therefore comparable with an OMChemSim <code>H_p[1]</code> only as a <i>difference</i> between two states, never as an absolute number.</p></body></html>"));
  end SteamStream;

  model TwoStreams "One steam-table water stream and one Peng-Robinson hydrocarbon stream"
    extends Modelica.Icons.Example;
    import data = Simulator.Files.ChemsepDatabase;

    //--- Hydrocarbon component set: a light NGL cut ---------------------------
    parameter data.Propane c3;
    parameter data.Nbutane nc4;
    parameter data.Npentane nc5;
    parameter Integer Nc = 3 "Number of hydrocarbon components";
    parameter data.GeneralProperties C[Nc] = {c3, nc4, nc5};

    //--- Specifications, as parameters so a sweep can override them at run time
    parameter Modelica.Units.SI.AbsolutePressure P_hc = 5e5 "Hydrocarbon stream pressure";
    parameter Modelica.Units.SI.Temperature T_hc = 320 "Hydrocarbon stream temperature";
    parameter Real F_hc(unit = "mol/s") = 100 "Hydrocarbon stream molar flow";
    parameter Real z_c3 = 0.5 "Propane mole fraction in the feed";
    parameter Real z_nc4 = 0.3 "n-Butane mole fraction in the feed";

    parameter Modelica.Units.SI.AbsolutePressure P_w = 10e5 "Water stream pressure";
    parameter Modelica.Units.SI.Temperature T_w = 500 "Water stream temperature";
    parameter Real F_w(unit = "mol/s") = 100 "Water stream molar flow";

    /* Start value for the vapour fraction of the hydrocarbon flash. The one
       InitialGuess derives assumes an equimolar feed, which Peng-Robinson is
       much less forgiving about than Raoult: started too far from the answer it
       either fails to initialise, or converges on a root of the Rachford-Rice
       closure that lies outside [0, 1] and is not a vapour fraction at all.
       Both are start-value problems -- nudge this towards the split you expect
       and try again. It cannot change the converged answer. */
    parameter Real xvap_guess = 0.5 "Start value for HC.xvap";

    //--- The two streams ------------------------------------------------------
    /* Pg, Tg_user and xg_user seed the start values from the same parameters
       that carry the specification, so an overridden operating point gets an
       initial guess that follows it instead of one frozen at the defaults. */
    Composites.MS_PR HC(Nc = Nc, C = C, Pg = P_hc, Tg_user = T_hc,
                        xg_user = {z_c3, z_nc4, 1 - z_c3 - z_nc4},
                        xvap(start = xvap_guess))
      "Hydrocarbon stream, Peng-Robinson"
      annotation(Placement(visible = true, transformation(origin = {0, 40}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));

    SteamStream W "Water stream, IF97 steam tables"
      annotation(Placement(visible = true, transformation(origin = {0, -40}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));

    //--- Reported side by side ------------------------------------------------
    /* OMChemSim carries molar flow in mol/s and molecular weight in kg/kmol
       (g/mol), so its Fm_p is numerically grams per second even though the
       declaration says kg/s. SteamStream.Fm is genuine kg/s. Convert before
       adding them -- this is exactly the kind of seam that appears whenever two
       libraries meet in one model. */
    Real Fm_hc(unit = "kg/s") "Hydrocarbon mass flow, converted to true kg/s";
    Real Fm_total(unit = "kg/s") "Total mass flow through the model";

  equation
    HC.P = P_hc;
    HC.T = T_hc;
    HC.F_p[1] = F_hc;
    HC.x_pc[1, :] = {z_c3, z_nc4, 1 - z_c3 - z_nc4};

    W.P = P_w;
    W.T = T_w;
    W.F = F_w;

    Fm_hc = HC.Fm_p[1] / 1000;
    Fm_total = Fm_hc + W.Fm;

    annotation(
      experiment(StartTime = 0, StopTime = 1, Tolerance = 1e-6, Interval = 1),
      Documentation(info = "<html><body><p>Two streams, two property methods, one model.</p><ul><li><b>HC</b> -- propane / n-butane / n-pentane, flashed with Peng-Robinson. Watch <code>HC.xvap</code>, <code>HC.K_c[:]</code>, <code>HC.Pbubl</code> and <code>HC.Pdew</code>.</li><li><b>W</b> -- pure water on the IF97 steam tables. Watch <code>W.h</code>, <code>W.d</code>, <code>W.Tsat</code> and <code>W.dTsup</code>.</li></ul><p>Both are algebraic: there is no time derivative anywhere, so the simulation is a single steady-state solve and any stop time will do.</p></body></html>"));
  end TwoStreams;

  model StreamSweep "The same two streams, with the operating point walked over simulation time"
    extends Modelica.Icons.Example;
    import data = Simulator.Files.ChemsepDatabase;

    /* Neither stream has a time derivative in it, so this is not a dynamic
       model: it is a sequence of steady-state solves, one per output interval,
       with the operating point moved a little between each. Two things follow.

       1. It is a legitimate one-factor-at-a-time experiment. Set the _start and
          _end pair of whichever specification you want to vary, leave the rest
          equal, and the result file is that factor's response curve. Vary two
          pairs at once and you get a diagonal path through the space, not a
          grid -- for a grid, use tools/run_doe.py.

       2. It is far more robust than solving each point cold. Every step starts
          from the previous converged solution, which is what carries a
          Peng-Robinson flash across the two-phase region without landing on a
          spurious root. */

    parameter data.Propane c3;
    parameter data.Nbutane nc4;
    parameter data.Npentane nc5;
    parameter Integer Nc = 3;
    parameter data.GeneralProperties C[Nc] = {c3, nc4, nc5};

    //--- Sweep endpoints. Equal start and end means "hold this one fixed". ----
    /* Defaults sit inside the two-phase envelope of this feed at 5 bar and stay
       there: 305 K is above its bubble point and 318 K below its dew point.
       See the caveat on StreamSweep below before widening them. */
    parameter Modelica.Units.SI.Temperature T_hc_start = 305 "Hydrocarbon temperature at t = StartTime";
    parameter Modelica.Units.SI.Temperature T_hc_end = 318 "Hydrocarbon temperature at t = StopTime";
    parameter Modelica.Units.SI.AbsolutePressure P_hc_start = 5e5 "Hydrocarbon pressure at t = StartTime";
    parameter Modelica.Units.SI.AbsolutePressure P_hc_end = 5e5 "Hydrocarbon pressure at t = StopTime";
    parameter Real z_c3_start = 0.5 "Propane mole fraction at t = StartTime";
    parameter Real z_c3_end = 0.5 "Propane mole fraction at t = StopTime";
    parameter Real z_nc4 = 0.3 "n-Butane mole fraction (held; n-pentane makes up the balance)";
    parameter Real F_hc(unit = "mol/s") = 100 "Hydrocarbon molar flow";

    parameter Modelica.Units.SI.Temperature T_w_start = 460 "Water temperature at t = StartTime";
    parameter Modelica.Units.SI.Temperature T_w_end = 700 "Water temperature at t = StopTime";
    parameter Modelica.Units.SI.AbsolutePressure P_w_start = 10e5 "Water pressure at t = StartTime";
    parameter Modelica.Units.SI.AbsolutePressure P_w_end = 10e5 "Water pressure at t = StopTime";
    parameter Real F_w(unit = "mol/s") = 100 "Water molar flow";

    parameter Modelica.Units.SI.Time t_start = 0 "StartTime of the experiment";
    parameter Modelica.Units.SI.Time t_stop = 100 "StopTime of the experiment";

    /* With T and P held as parameters the compiler can resolve the phase-region
       branch before the solver ever runs, and the flash that is left is small.
       Here they are time-varying, so all three branches stay live and the
       initial solve at t = t_start is a much larger algebraic system -- large
       enough that the equimolar vapour-fraction guess derived by InitialGuess
       is no longer good enough for Peng-Robinson. This start value is what
       makes the sweep initialise; it does not change the answer. */
    parameter Real xvap_guess = 0.5 "Start value for HC.xvap at t = t_start";

    Real tau(unit = "-") "Sweep coordinate, 0 at StartTime and 1 at StopTime";

    Composites.MS_PR HC(Nc = Nc, C = C, Pg = P_hc_start, Tg_user = T_hc_start,
                        xg_user = {z_c3_start, z_nc4, 1 - z_c3_start - z_nc4},
                        xvap(start = xvap_guess))
      "Hydrocarbon stream, Peng-Robinson";
    SteamStream W "Water stream, IF97 steam tables";

    Real Fm_hc(unit = "kg/s") "Hydrocarbon mass flow, converted to true kg/s";

  equation
    tau = (time - t_start) / (t_stop - t_start);

    HC.T = T_hc_start + tau * (T_hc_end - T_hc_start);
    HC.P = P_hc_start + tau * (P_hc_end - P_hc_start);
    HC.F_p[1] = F_hc;
    HC.x_pc[1, 1] = z_c3_start + tau * (z_c3_end - z_c3_start);
    HC.x_pc[1, 2] = z_nc4;
    HC.x_pc[1, 3] = 1 - HC.x_pc[1, 1] - HC.x_pc[1, 2];

    W.T = T_w_start + tau * (T_w_end - T_w_start);
    W.P = P_w_start + tau * (P_w_end - P_w_start);
    W.F = F_w;

    Fm_hc = HC.Fm_p[1] / 1000;

    annotation(
      experiment(StartTime = 0, StopTime = 100, Tolerance = 1e-6, Interval = 0.5),
      Documentation(info = "<html><body><p>A one-factor-at-a-time sweep of the two streams in <a href=\"modelica://MultiStream.TwoStreams\">TwoStreams</a>. As shipped it walks temperature: the hydrocarbon feed from 305 K to 318 K at 5 bar, giving a boiling curve from <code>xvap</code> = 0.46 to 0.87; and the water from 460 K to 700 K at 10 bar, entirely above <code>Tsat</code> = 453 K.</p><p>Plot <code>HC.xvap</code> against <code>HC.T</code>, and <code>W.h</code> or <code>W.d</code> against <code>W.T</code>.</p><p><b>Keep the sweep inside one phase region.</b> Driving T and P from time keeps all three region branches of the flash live at once, and in that form the vendored library will not initialise a Peng-Robinson stream whose first point is a subcooled liquid or a superheated vapour, nor switch region reliably partway through -- <code>xvap</code> runs past 1 and the simulation stops early. For a study that crosses a phase boundary use <code>tools/run_doe.py</code> instead.</p><p><b>Keep <code>t_start</code> and <code>t_stop</code> equal to the experiment StartTime and StopTime</b> -- they are what maps simulation time onto the sweep coordinate <code>tau</code>.</p></body></html>"));
  end StreamSweep;

  annotation(
    Documentation(info = "<html><body><p>Companion models for the material-stream guide. See <code>03_Multi_Stream/README.md</code> for how to load OMChemSim and the Modelica Standard Library in the right order.</p></body></html>"));
end MultiStream;
