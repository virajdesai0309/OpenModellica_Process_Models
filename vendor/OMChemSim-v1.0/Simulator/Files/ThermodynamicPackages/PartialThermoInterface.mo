within Simulator.Files.ThermodynamicPackages;

partial model PartialThermoInterface
  "The contract between a host model and a thermodynamic package"

  /* ---------------------------------------------------------------------
     NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md).

     OMChemSim composes a flowsheet model out of two independent halves that
     are mixed into one class:

         model MS
           extends Simulator.Streams.MaterialStream;                  // host
           extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;  // package
         end MS;

     The two halves reference each other's variables: MaterialStream uses
     K_c and the residual properties, RaoultsLaw uses P, T and x_pc. Upstream
     declared each variable in whichever half happened to write it and relied
     on both halves being flattened into a single scope before any name was
     resolved.

     OpenModelica's new frontend resolves a name against the class's own
     scope and its ancestors only -- never sideways into a sibling base class
     that happens to be mixed in alongside. So every one of those cross
     references now fails, e.g.

         Error: Variable Nc not found in scope RaoultsLaw.
         Error: Variable gmabubl_c[:] not found in scope Flash.
         Error: Variable K_c[:] not found in scope ShortcutColumn.

     Marking the classes `partial` does not help; the lookup is not deferred.
     The only way to make the reference legal is to declare the shared
     variables in a class that is a genuine ancestor of BOTH halves, which is
     what this model is. Every host and every thermodynamic package extends
     it, so each half now finds the other half's variables by ordinary upward
     lookup.

     This class holds declarations only -- no equations. That is deliberate:
     when a host and a package are mixed, this class is reached twice, and
     Modelica merges identical inherited declarations but DUPLICATES
     inherited equation sections. Keep it declaration-only or the composite
     model becomes over-determined.

     One consequence for callers: because Nc and C are inherited through two
     paths, a modification must not be attached to just one of them.

         extends MaterialStream(Nc = 2, C = {eth, wat});   // WRONG
         extends RaoultsLaw;                               // -> "Duplicate
                                                           //  elements not
                                                           //  identical"

     Put the modification below the diamond instead -- define the composite
     with unmodified extends and specify Nc and C where you use it:

         partial model MS
           extends MaterialStream;
           extends RaoultsLaw;
         end MS;
         ...
         MS S1(Nc = 2, C = {eth, wat});

     or, if you want a single self-contained model, repeat the modification
     on both extends clauses so the two inherited elements are identical.
     --------------------------------------------------------------------- */

  extends Simulator.GuessModels.InitialGuess;

  //--- Supplied by the HOST model, consumed by the thermodynamic package ---
  Real P(unit = "Pa", min = 0, start = Pg) "Pressure";
  Real T(unit = "K", min = 0, start = Tg) "Temperature";
  Real x_pc[3, Nc](each unit = "-", each min = 0, each max = 1, start = {xguess, xg, yg})
    "Component mole fraction in phase (1 mixture, 2 liquid, 3 vapour)";
  Real Pbubl(unit = "Pa", min = 0, start = Pmax) "Bubble point pressure";
  Real Pdew(unit = "Pa", min = 0, start = Pmin) "Dew point pressure";

  //--- Supplied by the thermodynamic PACKAGE, consumed by the host model ---
  Real K_c[Nc](each min = 0, start = K_guess) "Equilibrium K-value per component";
  Real gma_c[Nc](each start = 1) "Liquid activity coefficient at stream conditions";
  Real Pvap_c[Nc](each unit = "Pa", each min = 0) "Pure component vapour pressure at T";
  Real Cpres_p[3] "Residual molar heat capacity per phase";
  Real Hres_p[3] "Residual molar enthalpy per phase";
  Real Sres_p[3] "Residual molar entropy per phase";
  Real gmabubl_c[Nc](each start = 1) "Liquid activity coefficient at bubble point";
  Real gmadew_c[Nc](each start = 1) "Liquid activity coefficient at dew point";
  Real philiqbubl_c[Nc](each start = 1) "Liquid fugacity coefficient at bubble point";
  Real phivapdew_c[Nc](each start = 1) "Vapour fugacity coefficient at dew point";

end PartialThermoInterface;
