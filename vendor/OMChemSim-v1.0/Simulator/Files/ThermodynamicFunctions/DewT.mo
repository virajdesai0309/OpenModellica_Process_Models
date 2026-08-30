within Simulator.Files.ThermodynamicFunctions;

function DewT
  "Ideal (Raoult) dew-point temperature of a mixture at a given pressure"
  extends Modelica.Icons.Function;
  /* Solves  sum_i y_i / Psat_i(T) = 1/P  for T, by bisection.

     Same bracket as BubbleT -- between the lowest and highest pure-component
     saturation temperature at this pressure -- and it is valid for the same
     reason, with the inequalities reversed because the sum is monotonically
     decreasing in T:
       at T = min_i Tsat_i,  every Psat_j(T) <= P, so sum y_j/Psat_j >= 1/P
       at T = max_i Tsat_i,  every Psat_j(T) >= P, so sum y_j/Psat_j <= 1/P
     The dew temperature always comes out >= the bubble temperature computed
     by BubbleT over the same bracket. */
  input Real VP_c[:, 6] "Vapour-pressure coefficients per component";
  input Real Tc_c[size(VP_c, 1)](each unit = "K") "Critical temperature per component";
  input Real Pc_c[size(VP_c, 1)](each unit = "Pa") "Critical pressure per component";
  input Real y_c[size(VP_c, 1)] "Mole fraction per component";
  input Real P(unit = "Pa") "Pressure";
  output Real T(unit = "K") "Dew-point temperature";
protected
  constant Integer nIter = 100 "Bisection steps";
  constant Real PsatFloor = 1e-30 "Guards 1/Psat against underflow to zero";
  Integer Nc = size(VP_c, 1);
  Real Tsat_c[size(VP_c, 1)];
  Real Tlo, Thi, Tmid, Rsum;
algorithm
  for i in 1:Nc loop
    Tsat_c[i] := Simulator.Files.ThermodynamicFunctions.SatT(VP_c[i, :], Tc_c[i], Pc_c[i], P);
  end for;
  Tlo := min(Tsat_c);
  Thi := max(Tsat_c);
  if Thi <= Tlo then
    T := Tlo;
    return;
  end if;
  for k in 1:nIter loop
    Tmid := 0.5 * (Tlo + Thi);
    Rsum := 0;
    for i in 1:Nc loop
      Rsum := Rsum + y_c[i] / max(Simulator.Files.ThermodynamicFunctions.Psat(VP_c[i, :], Tmid), PsatFloor);
    end for;
    if Rsum > 1 / P then
      Tlo := Tmid;
    else
      Thi := Tmid;
    end if;
  end for;
  T := 0.5 * (Tlo + Thi);
end DewT;
