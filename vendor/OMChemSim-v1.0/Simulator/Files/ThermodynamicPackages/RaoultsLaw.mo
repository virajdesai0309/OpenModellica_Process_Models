within Simulator.Files.ThermodynamicPackages;

  model RaoultsLaw
    "Ideal thermodynamic package: modified Raoult's Law for VLE (K_c = Psat/P)"

    // --- PATCH NOTE (not in upstream v1.0) -----------------------------
    // The original file had: import Simulator.Files.Thermodynamic_Functions.*;
    // That package does not exist (typo: extra underscore, wrong casing).
    // The correct folder is Simulator.Files.ThermodynamicFunctions, and every
    // call below already uses that correct, fully-qualified name directly,
    // so the import was unused dead code. Removed rather than corrected,
    // since nothing in this file actually relies on the unqualified import.
    // ---------------------------------------------------------------------

    // --- PATCH NOTE #2 (not in upstream v1.0) -----------------------------
    // K_c, Cpres_p, Hres_p, Sres_p, gmabubl_c, gmadew_c, philiqbubl_c, and
    // phivapdew_c used to be declared directly here. But MaterialStream.mo
    // references all eight of them too, and MaterialStream is only ever
    // combined with RaoultsLaw as a SIBLING (both extended together by a
    // stream model like MyFirstStream) -- not as an ancestor/descendant.
    // OpenModelica only resolves names through a class's own ancestor
    // chain, never sideways into a sibling's declarations, so
    // MaterialStream failed with "Variable Cpres_p not found in scope
    // MaterialStream" even though RaoultsLaw clearly declared it.
    //
    // Fix: all eight variables now live in one shared ancestor,
    // Simulator.Files.ThermodynamicPackages.PartialThermoResults, which
    // both MaterialStream and RaoultsLaw extend. gma_c and Pvap_c stay
    // declared locally below since MaterialStream never references them --
    // they're purely internal working variables for this file's own
    // K-value calculation.
    // ------------------------------------------------------------------------
    extends Simulator.Files.ThermodynamicPackages.PartialThermoInterface;

    // gma_c[Nc]  : Liquid-phase activity coefficient per component --
    //              captures non-ideal liquid mixing (e.g. azeotropes).
    //              Stays local: only used internally below, never by
    //              MaterialStream directly.
    // Pvap_c[Nc] : Pure-component vapor pressure at stream temperature T,
    //              from the Antoine-type correlation (see Psat below).
    //              Stays local for the same reason.

  equation

    // --- Ideality assumptions that define "Raoult's Law" ----------------
    // Setting every activity and fugacity coefficient to 1 means:
    //   - the liquid phase is treated as an ideal solution (no gamma effects,
    //     so no azeotrope behavior can be captured), and
    //   - the vapor phase is treated as an ideal gas (no phi corrections,
    //     valid mainly at low-to-moderate pressure).
    // This is the same simplifying assumption DWSim's "Raoult's Law" /
    // ideal property package makes — fine for well-behaved, low-pressure
    // systems, but will misestimate genuinely non-ideal pairs like
    // ethanol-water near their azeotrope.
    for i in 1:Nc loop
      gma_c[i] = 1;
      gmabubl_c[i] = 1;
      gmadew_c[i] = 1;
      philiqbubl_c[i] = 1;
      phivapdew_c[i] = 1;
    end for;

    // --- Pure-component vapor pressure at stream temperature T ----------
    // C[i].VP is the 6-coefficient Antoine-type array pulled straight from
    // the Chemsep compound record (see e.g. Water.mo's VP = {101, ...}).
    // Psat evaluates: Pvap = exp(VP2 + VP3/T + VP4*ln(T) + VP5*T^VP6)
    for i in 1:Nc loop
      Pvap_c[i] = Simulator.Files.ThermodynamicFunctions.Psat(C[i].VP, T);
    end for;

    // --- Modified Raoult's Law K-value -----------------------------------
    // With gamma = phi = 1 (ideal assumption above), the general VLE
    // equilibrium relation y_i*phi_v*P = x_i*gamma_i*phi_l*Psat_i collapses
    // to the textbook form: K_i = Psat_i / P
    // This K_c array is what MaterialStream.mo uses to solve x_pc[3,i]
    // (vapor composition) from x_pc[2,i] (liquid composition) during flash.
    for j in 1:Nc loop
      K_c[j] = Pvap_c[j] / P;
    end for;

    // --- Residual properties are zero under ideal-gas/ideal-solution -----
    // Because there's no non-ideality (gamma = phi = 1 above), there is no
    // "correction" needed on top of ideal-gas Cp, H, S — so all residual
    // terms that MaterialStream.mo adds to its phase properties are zero.
    // (See MaterialStream.mo: Cp_p[i] = ... + Cpres_p[i], etc.)
    Cpres_p[:] = zeros(3);
    Hres_p[:] = zeros(3);
    Sres_p[:] = zeros(3);

  end RaoultsLaw;
