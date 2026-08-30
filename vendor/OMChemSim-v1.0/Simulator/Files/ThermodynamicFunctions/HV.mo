within Simulator.Files.ThermodynamicFunctions;

  function HV
    /*Returns Heat of Vaporization*/
    extends Modelica.Icons.Function;
    input Real HOV[6] "from chemsep database";
    input Real Tc(unit = "K") "Critical Temperature";
    input Real T(unit = "K") "Temperature";
    output Real Hvap(unit = "J/mol") "Heat of Vaporization";
  protected
    /* The DIPPR-106 form below is only defined for 0 <= Tr < 1. Upstream
       guarded the upper end but not the lower one, so a solver iterate that
       overshot into negative temperature produced Tr << 0, hence a base
       (1 - Tr) far above 1 raised to a cubic-in-Tr exponent in the thousands.
       That overflows to infinity and aborts the whole run:

         Invalid root: (18.8383)^(27009.3)

       Clamping Tr at 0 keeps the correlation finite and continuous there
       (it returns HOV[2]/1000), so the solver can iterate back into the
       physical range instead of the simulation terminating. No effect at any
       physically meaningful temperature. */
    Real Tr = max(T / Tc, 0);
  algorithm
    if T < Tc then
      Hvap := HOV[2] * (1 - Tr) ^ (HOV[3] + HOV[4] * Tr + HOV[5] * Tr ^ 2 + HOV[6] * Tr ^ 3) / 1000;
    else
      Hvap := 0;
    end if;
  end HV;
