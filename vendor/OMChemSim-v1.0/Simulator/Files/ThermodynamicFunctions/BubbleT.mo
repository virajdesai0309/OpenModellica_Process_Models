within Simulator.Files.ThermodynamicFunctions;

function BubbleT
  "Ideal (Raoult) bubble-point temperature of a mixture at a given pressure"
  extends Modelica.Icons.Function;
  /* Solves  sum_i x_i * Psat_i(T) = P  for T, by bisection.

     The bracket is the interval between the lowest and the highest
     pure-component saturation temperature at this pressure. That bracket is
     provably valid and needs no tuning:
       at T = min_i Tsat_i,  every Psat_j(T) <= P, so sum x_j Psat_j <= P
       at T = max_i Tsat_i,  every Psat_j(T) >= P, so sum x_j Psat_j >= P
     and the sum is monotonically increasing in T, so exactly one root lies
     inside. This is what makes the routine safe for any component set and any
     pressure, instead of relying on hand-picked start values. */
  input Real VP_c[:, 6] "Vapour-pressure coefficients per component";
  input Real Tc_c[size(VP_c, 1)](each unit = "K") "Critical temperature per component";
  input Real Pc_c[size(VP_c, 1)](each unit = "Pa") "Critical pressure per component";
  input Real x_c[size(VP_c, 1)] "Mole fraction per component";
  input Real P(unit = "Pa") "Pressure";
  output Real T(unit = "K") "Bubble-point temperature";
protected
  constant Integer nIter = 100 "Bisection steps";
  Integer Nc = size(VP_c, 1);
  Real Tsat_c[size(VP_c, 1)];
  Real Tlo, Thi, Tmid, Psum;
algorithm
  for i in 1:Nc loop
    Tsat_c[i] := Simulator.Files.ThermodynamicFunctions.SatT(VP_c[i, :], Tc_c[i], Pc_c[i], P);
  end for;
  Tlo := min(Tsat_c);
  Thi := max(Tsat_c);
  if Thi <= Tlo then
    /* Single component, or all components boiling at the same temperature:
       the bracket has collapsed onto the answer already. */
    T := Tlo;
    return;
  end if;
  for k in 1:nIter loop
    Tmid := 0.5 * (Tlo + Thi);
    Psum := 0;
    for i in 1:Nc loop
      Psum := Psum + x_c[i] * Simulator.Files.ThermodynamicFunctions.Psat(VP_c[i, :], Tmid);
    end for;
    if Psum < P then
      Tlo := Tmid;
    else
      Thi := Tmid;
    end if;
  end for;
  T := 0.5 * (Tlo + Thi);
end BubbleT;
