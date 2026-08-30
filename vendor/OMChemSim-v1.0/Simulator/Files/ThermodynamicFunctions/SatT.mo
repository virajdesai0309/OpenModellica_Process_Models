within Simulator.Files.ThermodynamicFunctions;

function SatT
  "Saturation temperature of a pure component at a given pressure"
  extends Modelica.Icons.Function;
  /* Inverts the DIPPR-101 vapour-pressure correlation used by Psat, i.e.
     solves  Psat(VP, T) = P  for T, by bisection.

     Bisection is used deliberately in preference to Newton: Psat is a stiff
     exponential whose derivative spans many orders of magnitude, so Newton
     readily overshoots into T <= 0 (where VP[3]/T flips sign and the
     correlation diverges). Bisection cannot leave its bracket, needs no
     derivative, needs no start value, and always terminates -- which is
     exactly what a guess-value generator needs. */
  input Real VP[6] "Vapour-pressure coefficients, from chemsep database";
  input Real Tc(unit = "K") "Critical temperature";
  input Real Pc(unit = "Pa") "Critical pressure";
  input Real P(unit = "Pa") "Pressure";
  output Real T(unit = "K") "Saturation temperature";
protected
  /* The bracket is anchored on the critical point rather than on arbitrary
     absolute temperatures, so it adapts to any compound in the database:
       at T = TfracLo*Tc the correlation gives a vapour pressure far below any
                         pressure of practical interest (typically < 1e-12 Pa),
       at T = Tc         it gives, by construction of the fit, ~Pc.
     Hence for any subcritical P the root is bracketed. */
  constant Real TfracLo = 0.15 "Lower bracket as a fraction of Tc";
  constant Integer nIter = 100 "Bisection steps; halves the bracket each time";
  Real Tlo, Thi, Tmid;
algorithm
  if P >= Pc then
    /* Supercritical: no saturation temperature exists. Return Tc, the closest
       physically meaningful anchor, rather than failing -- this function only
       ever feeds start values. */
    T := Tc;
    return;
  end if;
  Tlo := TfracLo * Tc;
  Thi := Tc;
  for i in 1:nIter loop
    Tmid := 0.5 * (Tlo + Thi);
    if Simulator.Files.ThermodynamicFunctions.Psat(VP, Tmid) < P then
      Tlo := Tmid;
    else
      Thi := Tmid;
    end if;
  end for;
  T := 0.5 * (Tlo + Thi);
end SatT;
