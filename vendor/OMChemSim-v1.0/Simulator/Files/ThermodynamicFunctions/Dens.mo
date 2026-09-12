within Simulator.Files.ThermodynamicFunctions;

  function Dens
    //This function is developed by swaroop katta
    //this function calculates density of pure componets as a function of temperature using chemsep database.
    extends Modelica.Icons.Function;
    input Real LiqDen[6], Tc, T, P;
    output Real rho "units kmol/m3";
  protected
    Real Tr;
  protected
    parameter Real R = 8.314 "gas constant";
  algorithm
    Tr := T / Tc;
    if T < Tc then
      if LiqDen[1] == 105 then
        rho := LiqDen[2] / LiqDen[3] ^ (1 + (1 - T / LiqDen[4]) ^ LiqDen[5]) * 1000;
      elseif LiqDen[1] == 106 then
        rho := LiqDen[2] * (1 - Tr) ^ (LiqDen[3] + LiqDen[4] * Tr + LiqDen[5] * Tr ^ 2 + LiqDen[6] * Tr ^ 3) * 1000;
      else
        /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md). There was no else branch,
           so an unrecognised correlation form left the output unassigned and
           the function returned 0.0. Every caller divides by the result --
           CentrifugalPump's rho = 1/sum(x./rho_c), and the liquid-volume terms
           in NRTL and UNIQUAC -- so the symptom was a division by zero a long
           way from the cause. Eight of the 431 compounds in the bundled
           Chemsep database carry LiqDen = {0, 0, 0, 0, 0, 0} and have no
           correlation at all: the six carbonates (DiButyl, DiEthyl, DiPhenyl,
           EthylPhenyl, MethylEthyl, MethylPhenyl), TwoMethoxyTwoMethylHeptane
           and TwoMethylTwoHeptanol. Fail here, where the compound can be
           named, instead of downstream. */
        rho := 0;
        assert(false, "Dens: no liquid density correlation is implemented for DIPPR form "
                      + String(LiqDen[1]) + " (only 105 and 106 are). A LiqDen[1] of 0 means the "
                      + "compound has no density data in the bundled Chemsep database at all; "
                      + "substitute a compound that has one.");
      end if;
    else
      rho := P / (R * T * 1000);
    end if;
  end Dens;
