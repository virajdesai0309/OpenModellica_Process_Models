within Simulator.Files.ThermodynamicPackages;

 model PengRobinson
  
  //=====================================================================
  //Header files and Parameters
    import Simulator.Files.*;
    parameter Real R = 8.314 "Ideal Gas Constant";
    parameter Real kij_c[Nc, Nc](each start = 1) = Simulator.Files.ThermodynamicFunctions.BIPPR(Nc, C.name);
  
  //======================================================================
  //Model Variables
    Real Tr_c[Nc](each start = Tg) "Reduced temperature";
    Real b_c[Nc];
    Real a_c[Nc](start = xg);
    Real m_c[Nc];
    Real q_c[Nc];
    Real aij_c[Nc, Nc];
    Real philiq_c[Nc](each start = 5) "Liquid Phase Fugasity coefficient";
    Real phivap_c[Nc](each start = 5) "Vapor Phase Fugasity coefficient";
    Real aMliq, bMliq;
    Real Aliq(start=xliqg), Bliq(start=xvapg);
    Real Cliq[4];
    Real Z_RL[3, 2](each start = xliqg);
    Real Zliq[3](each start = xliqg), Zll(start = xvapg);
    Real sumxliq[Nc];
    Real aMvap, bMvap;
    Real Avap(start=xliqg), Bvap(start=xvapg);
    Real Cvap[4];
    Real Z_RV[3, 2](each start = xvapg);
    Real Zvap[3](each start = xvapg), Zvv;
    Real sumxvap[Nc];
    Real A, B, Cdummy, D_c[Nc], E, F, G, H_c[Nc], I_c[Nc], J_c[Nc];
    /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md): the A/(B*sqrt(8)) prefactor of
       each log-fugacity expression, guarded against the absent phase. Outside
       the two-phase region MaterialStream zeroes one phase's composition, which
       drives that phase's aM and bM -- and therefore its A and B -- to zero, and
       the unguarded quotient evaluates 0/0. Symptom: a Peng-Robinson stream
       solves inside the two-phase envelope and fails with `Iteration variable
       ... is inf or nan` as soon as it is asked for a subcooled liquid or a
       superheated vapour. With the prefactor zeroed the absent phase gets a
       fugacity coefficient of 1, which nothing in that branch reads. */
    Real lnphiliqfac "Aliq / (Bliq * sqrt(8)) * log(A / B), zero when no liquid is present";
    Real lnphivapfac "Avap / (Bvap * sqrt(8)) * log(E / F), zero when no vapour is present";
    
    extends Simulator.Files.ThermodynamicPackages.PartialThermoInterface;
  //======================================================================
  equation
    for i in 1:Nc loop
      Pvap_c[i] = Simulator.Files.ThermodynamicFunctions.Psat(C[i].VP, T);
      gmadew_c[i] = 1;
      gmabubl_c[i] = 1;
      philiqbubl_c[i] = 1;
      phivapdew_c[i] = 1;
      // gma_c is declared in PartialThermoInterface; upstream set a local
      // `gma` here instead, leaving gma_c with no equation (see ATTRIBUTION.md).
      gma_c[i] = 1;
    end for;
    Cpres_p[:] = zeros(3);
    Hres_p[:] = zeros(3);
    Sres_p[:] = zeros(3);
    Tr_c = T ./ C.Tc;
    b_c = 0.0778 * R * C.Tc ./ C.Pc;
    m_c = 0.37464 .+ 1.54226 * C.AF .- 0.26992 * C.AF .^ 2;
    q_c = 0.45724 * R ^ 2 * C.Tc .^ 2 ./ C.Pc;
    a_c = q_c .* (1 .+ m_c .* (1 .- sqrt(Tr_c))) .^ 2;
    aij_c = {{(1 - kij_c[i, j]) * sqrt(a_c[i] * a_c[j]) for i in 1:Nc} for j in 1:Nc};
    
  //======================================================================
//Liquid_Fugacity Coefficient Calculation Routine
    aMliq = sum({{x_pc[2, i] * x_pc[2, j] * aij_c[i, j] for i in 1:Nc} for j in 1:Nc});
    bMliq = sum(b_c .* x_pc[2, :]);
    Aliq = aMliq * P / (R * T) ^ 2;
    Bliq = bMliq * P / (R * T);
    Cliq[1] = 1;
    Cliq[2] = Bliq - 1;
    Cliq[3] = Aliq - 3 * Bliq ^ 2 - 2 * Bliq;
    Cliq[4] = Bliq ^ 3 + Bliq ^ 2 - Aliq * Bliq;
    Z_RL = Modelica.Math.Polynomials.roots(Cliq);
    Zliq = {Z_RL[i, 1] for i in 1:3};
    Zll = min({Zliq});
    sumxliq = {sum({x_pc[2, j] * aij_c[i, j] for j in 1:Nc}) for i in 1:Nc};
    if Zll + 2.4142135 * Bliq <= 0 then
      A = 1;
    else
      A = Zll + 2.4142135 * Bliq;
    end if;
    if Zll - 0.414213 * Bliq <= 0 then
      B = 1;
    else
      B = Zll - 0.414213 * Bliq;
    end if;
    if Zll - Bliq <= 0 then
      Cdummy = 0;
    else
      Cdummy = log(Zll - Bliq);
    end if;
    for i in 1:Nc loop
      if bMliq == 0 then
        D_c[i] = 0;
      else
        D_c[i] = b_c[i] / bMliq;
      end if;
    end for;
    for i in 1:Nc loop
      if aMliq == 0 then
        J_c[i] = 0;
      else
        J_c[i] = sumxliq[i] / aMliq;
      end if;
    end for;
    if Bliq <= 0 then
      lnphiliqfac = 0;
    else
      lnphiliqfac = Aliq / (Bliq * sqrt(8)) * log(A / B);
    end if;
    philiq_c = exp(lnphiliqfac .* (D_c .- 2 * J_c) .+ (Zll - 1) * D_c .- Cdummy);
  
  //======================================================================
//Vapour Fugacity Calculation Routine
    aMvap = sum({{x_pc[3, i] * x_pc[3, j] * aij_c[i, j] for i in 1:Nc} for j in 1:Nc});
    bMvap = sum(b_c .* x_pc[3, :]);
    Avap = aMvap * P / (R * T) ^ 2;
    Bvap = bMvap * P / (R * T);
    Cvap[1] = 1;
    Cvap[2] = Bvap - 1;
    Cvap[3] = Avap - 3 * Bvap ^ 2 - 2 * Bvap;
    Cvap[4] = Bvap ^ 3 + Bvap ^ 2 - Avap * Bvap;
    Z_RV = Modelica.Math.Polynomials.roots(Cvap);
    Zvap = {Z_RV[i, 1] for i in 1:3};
    Zvv = max({Zvap});
    sumxvap = {sum({x_pc[3, j] * aij_c[i, j] for j in 1:Nc}) for i in 1:Nc};
    // Guard tested Avap upstream while the branch below uses Bvap, so E could
    // be assigned a negative value and log(E / F) aborted the run
    // ("Argument of log(E / F) was -0.00694498"). See ATTRIBUTION.md.
    if Zvv + 2.4142135 * Bvap <= 0 then
      E = 1;
    else
      E = Zvv + 2.4142135 * Bvap;
    end if;
    if Zvv - 0.414213 * Bvap <= 0 then
      F = 1;
    else
      F = Zvv - 0.414213 * Bvap;
    end if;
    if Zvv - Bvap <= 0 then
      G = 0;
    else
      G = log(Zvv - Bvap);
    end if;
    for i in 1:Nc loop
      if bMvap == 0 then
        H_c[i] = 0;
      else
        H_c[i] = b_c[i] / bMvap;
      end if;
    end for;
    for i in 1:Nc loop
      if aMvap == 0 then
        I_c[i] = 0;
      else
        I_c[i] = sumxvap[i] / aMvap;
      end if;
    end for;
    if Bvap <= 0 then
      lnphivapfac = 0;
    else
      lnphivapfac = Avap / (Bvap * sqrt(8)) * log(E / F);
    end if;
    phivap_c = exp(lnphivapfac .* (H_c .- 2 * I_c) .+ (Zvv - 1) * H_c .- G);
    for i in 1:Nc loop
      if philiq_c[i] == 0 or phivap_c[i] == 0 then
        K_c[i] = 0;
      else
        K_c[i] = philiq_c[i] / phivap_c[i];
      end if;
    end for;
  end PengRobinson;

  //=============================================================================================================
