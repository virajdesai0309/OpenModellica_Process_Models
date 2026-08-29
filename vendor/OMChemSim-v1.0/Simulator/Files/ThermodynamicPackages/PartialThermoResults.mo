within Simulator.Files.ThermodynamicPackages;

partial model PartialThermoResults
  "Shared VLE result variables: declared once here, consumed by MaterialStream, produced by whichever property package (RaoultsLaw, NRTL, etc.) is extended alongside it"
  extends Simulator.GuessModels.InitialGuess; // was GuessInput -- InitialGuess also gives us Tg for T's start value

  Real P(unit = "Pa", min = 0, start = Pg) "Pressure";
  Real T(unit = "K", start = Tg) "Temperature";

  Real K_c[Nc](each min = 0) "Equilibrium K-value per component";
  Real Cpres_p[3] "Residual molar heat capacity per phase";
  Real Hres_p[3] "Residual molar enthalpy per phase";
  Real Sres_p[3] "Residual molar entropy per phase";
  Real gmabubl_c[Nc] "Liquid activity coefficient at bubble point";
  Real gmadew_c[Nc] "Liquid activity coefficient at dew point";
  Real philiqbubl_c[Nc] "Liquid fugacity coefficient at bubble point";
  Real phivapdew_c[Nc] "Vapor fugacity coefficient at dew point";
end PartialThermoResults;
