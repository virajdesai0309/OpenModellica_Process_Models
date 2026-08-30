within Simulator.GuessModels;

partial model InitialGuess
  "Generates start values for every stream/unit variable, from the component set alone"

  /* ---------------------------------------------------------------------
     REWRITTEN vs upstream v1.0 (see ATTRIBUTION.md).

     Upstream declared every guess below as `parameter Real x(fixed = false)`
     and computed them in an `initial equation` section. That turns guess
     generation into a ~45-equation coupled non-linear initialisation system
     that the solver must crack BEFORE it can start on the actual process
     model -- and it is a system with no reliable start values of its own,
     containing 1/Px, 1/Psatt and Real-valued equality branches. It also could
     not survive being inherited twice (see the diamond note in
     MaterialStream.mo), because an `initial equation` section is duplicated
     once per extends path while the variables it solves for are merged into
     one.

     Symptom on OpenModelica 1.27: "The initial conditions are over specified.
     The following 90 initial equations are redundant", followed by the
     compiler dropping an arbitrary subset of the duplicates, leaving Psatt
     unsolved at its default 0.0, and finally
     "division by zero at time 0, (a=0.5)/(b=0) ... divisor Psatt[2]".

     Every guess is now a plain parameter with a binding equation, evaluated
     top-down by direct computation. Consequences:
       - there is no initialisation system for the guesses at all, so it
         cannot be singular, over-specified or unsolvable;
       - nothing depends on hand-tuned start attributes, so the model is no
         longer silently specialised to one chemical system;
       - the model is safe to inherit through several paths at once, because
         parameter declarations merge across extends paths whereas equations
         do not.
     --------------------------------------------------------------------- */

  extends GuessInput;

protected
  /* --- Feed composition assumed for guessing -------------------------------
     Equimolar. The real composition is a specification on the instantiated
     model and is not visible here, so an equimolar split is the neutral
     choice -- it is only ever used to seed the solver. */
  parameter Real xgsum = sum(xg_user);
  parameter Real xguess[Nc] = if xgsum > 0 then xg_user / xgsum else fill(1 / Nc, Nc)
    "Assumed feed mole fraction: the user-supplied anchor if given, else equimolar";

  /* --- Pure-component and mixture saturation states at Pg ------------------
     Tbg / Tdg bracket the two-phase region of this component set at the guess
     pressure, and Temp sits in the middle of it -- so Temp is guaranteed to
     be a temperature at which every Psat below is strictly positive and of a
     sane magnitude. This is what removes the division-by-zero class of
     failure at its source, rather than papering over it with start values. */
  parameter Real VPmat[Nc, 6] = {C[i].VP for i in 1:Nc} "Vapour-pressure coefficients, gathered as a matrix";
  parameter Real Tcrit[Nc] = {C[i].Tc for i in 1:Nc} "Critical temperature per component";
  parameter Real Pcrit[Nc] = {C[i].Pc for i in 1:Nc} "Critical pressure per component";

  parameter Real Tbg = Simulator.Files.ThermodynamicFunctions.BubbleT(VPmat, Tcrit, Pcrit, xguess, Pg) "Bubble-point temperature guess";
  parameter Real Tdg = Simulator.Files.ThermodynamicFunctions.DewT(VPmat, Tcrit, Pcrit, xguess, Pg) "Dew-point temperature guess";
  parameter Real Temp = if Tg_user > 0 then Tg_user else 0.5 * (Tbg + Tdg)
    "Temperature guess: the user-supplied anchor if given, else mid two-phase";
  parameter Real Tg = Temp "Temperature guess";
  parameter Real Tc[Nc] = Tcrit "Critical temperature per component (retained: referenced by inheriting models)";

  parameter Real Psatt[Nc] = {Simulator.Files.ThermodynamicFunctions.Psat(C[i].VP, Temp) for i in 1:Nc} "Vapour pressure at Temp";
  parameter Real Psatbg[Nc] = {Simulator.Files.ThermodynamicFunctions.Psat(C[i].VP, Tbg) for i in 1:Nc} "Vapour pressure at Tbg";
  parameter Real Psatdg[Nc] = {Simulator.Files.ThermodynamicFunctions.Psat(C[i].VP, Tdg) for i in 1:Nc} "Vapour pressure at Tdg";

  parameter Real K_guess[Nc] = Psatt / Pg "Raoult K-value guess";

  /* --- Pressure bounds of the two-phase region at Temp ---------------------
     Pmin is the dew pressure and Pmax the bubble pressure of the equimolar
     mixture at Temp. The max(..., PsatFloor) is belt-and-braces: Psatt is
     already strictly positive by construction of Temp above. */
  parameter Real PsatFloor = 1e-30 "Guards the reciprocals below against underflow";
  parameter Real Pxc[Nc] = {xguess[i] / max(Psatt[i], PsatFloor) for i in 1:Nc};
  parameter Real Px = sum(Pxc);
  parameter Real Pmin = 1 / max(Px, PsatFloor) "Dew pressure at Temp";
  parameter Real Pxm[Nc] = {xguess[i] * Psatt[i] for i in 1:Nc};
  parameter Real Pmax = sum(Pxm) "Bubble pressure at Temp";

  /* --- Phase regime -------------------------------------------------------
     Resolved once, into an Integer, so the branches below compare Integers
     instead of Reals. Upstream branched on Real-valued equality against 1.0
     and 0.0, which modern OpenModelica flags as deprecated in a non-function
     context and which is in any case unsafe under floating point. */
  parameter Integer regime = if Pg >= Pmax then 1 elseif Pg >= Pmin then 2 else 3
    "1 = subcooled liquid, 2 = two-phase, 3 = superheated vapour";

  parameter Real xvapg = if regime == 1 then 0 elseif regime == 3 then 1 else (Pg - Pmin) / (Pmax - Pmin) "Vapour phase mole fraction guess";
  parameter Real xliqg = 1 - xvapg "Liquid phase mole fraction guess";
  parameter Real Beta = xvapg "Vapour fraction (already clamped to [0,1] by construction)";
  parameter Real Alpha = 1 - Beta;

  /* --- Phase compositions, from the Rachford-Rice relation -----------------
     In the two-phase regime y_i = z_i K_i / (1 + (K_i - 1) * beta) and
     x_i = y_i / K_i. In the single-phase regimes the absent phase is seeded
     with zeros, matching how MaterialStream zeroes it out in those branches. */
  parameter Real ymol[Nc] = if regime == 1 then zeros(Nc) else {xguess[i] * K_guess[i] / (1 + (K_guess[i] - 1) * xvapg) for i in 1:Nc};
  parameter Real xmol[Nc] = if regime == 1 then xguess elseif regime == 3 then zeros(Nc) else {ymol[i] / max(K_guess[i], PsatFloor) for i in 1:Nc};

  /* Clamped into [0,1]. Upstream wrote this as an if-chain whose second test
     read xg[i] > 1 -- referring to the variable being defined rather than to
     xmol[i]. min/max expresses the intended clamp without the self-reference. */
  parameter Real xg[Nc] = {min(1, max(0, xmol[i])) for i in 1:Nc} "Liquid composition guess";
  parameter Real yg[Nc] = {min(1, max(0, ymol[i])) for i in 1:Nc} "Vapour composition guess";

  /* --- Phase flow rates ---------------------------------------------------
     Upstream obtained these from a 2x2 solve of the overall and component
     mole balances; with the flash above already consistent, that solve
     reduces exactly to splitting Fg by the vapour fraction. */
  parameter Real Fvapg = Fg * xvapg "Vapour molar flow guess";
  parameter Real Fliqg = Fg * xliqg "Liquid molar flow guess";

  /* --- Enthalpies ---------------------------------------------------------
     Htotg = Hliqg + Hvapg is upstream's own definition and is kept as-is;
     these are start values, not a physical energy balance. */
  parameter Real Hcomplg[Nc] = {Simulator.Files.ThermodynamicFunctions.HLiqId(C[i].SH, C[i].VapCp, C[i].HOV, C[i].Tc, Temp) for i in 1:Nc};
  parameter Real Hcompvg[Nc] = {Simulator.Files.ThermodynamicFunctions.HVapId(C[i].SH, C[i].VapCp, C[i].HOV, C[i].Tc, Temp) for i in 1:Nc};
  parameter Real Hliqg = sum(xguess .* Hcomplg) "Liquid molar enthalpy guess";
  parameter Real Hvapg = sum(xguess .* Hcompvg) "Vapour molar enthalpy guess";
  parameter Real Htotg = Hliqg + Hvapg;
  parameter Real Hmixg = Htotg "Mixed-phase molar enthalpy guess";
  parameter Real Hcompg[Nc] = xguess * Htotg;

end InitialGuess;
