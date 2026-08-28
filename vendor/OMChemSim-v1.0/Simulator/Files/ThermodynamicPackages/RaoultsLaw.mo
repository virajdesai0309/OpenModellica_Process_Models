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

    // K_c[Nc]      : Equilibrium K-value per component (y_i = K_i * x_i),
    //                the core quantity every flash calculation needs.
    // Cpres_p[3]   : Residual molar heat capacity per phase (mixed/liq/vap).
    //                "Residual" = correction on top of ideal-gas behavior.
    // Hres_p[3]    : Residual molar enthalpy per phase.
    // Sres_p[3]    : Residual molar entropy per phase.
    Real K_c[Nc](each min = 0), Cpres_p[3], Hres_p[3], Sres_p[3];

    // gma_c[Nc]        : Liquid-phase activity coefficient per component —
    //                    captures non-ideal liquid mixing (e.g. azeotropes).
    // gmabubl_c[Nc]    : Activity coefficient evaluated at the bubble point.
    // gmadew_c[Nc]     : Activity coefficient evaluated at the dew point.
    Real gma_c[Nc], gmabubl_c[Nc], gmadew_c[Nc];

    // philiqbubl_c[Nc] : Liquid fugacity coefficient at the bubble point —
    //                    captures non-ideal *vapor* behavior (real-gas effects).
    // phivapdew_c[Nc]  : Vapor fugacity coefficient at the dew point.
    // Pvap_c[Nc]       : Pure-component vapor pressure at stream temperature T,
    //                    from the Antoine-type correlation (see Psat below).
    Real philiqbubl_c[Nc], phivapdew_c[Nc], Pvap_c[Nc];

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
