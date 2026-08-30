within Simulator.Files.Models.ReactionManager;

partial model PartialReactionInterface
  "The contract between a reactor model and a reaction model"

  /* ---------------------------------------------------------------------
     NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md).

     Exactly the same problem as PartialThermoInterface, in the reaction half
     of the library. A reactor and a reaction definition are mixed into one
     class and reference each other's variables across the join:

         model ConvReactor
           extends Simulator.UnitOperations.ConversionReactor;             // reactor
           extends Simulator.Files.Models.ReactionManager.ConversionReaction; // reaction
         end ConvReactor;

     The reaction half reads Nc and C, which the reactor half owns; the
     reactor half reads Nr, BC_r, Coef_cr and Hr_r, which the reaction half
     owns. Under OpenModelica's new frontend neither direction resolves:

         Error: Variable Nc not found in scope KineticReaction.
         Error: Variable Nr not found in scope ConversionReactor.
         Error: Variable BC_r[1] not found in scope EquilibriumReaction.

     (The last one is not even a sibling reference -- EquilibriumReaction is
     an ANCESTOR of EquilibriumReactor and was reading a variable declared in
     its own descendant.)

     Declaring the shared names here, in a common ancestor of both halves,
     makes every one of those references an ordinary upward lookup.

     Declaration-only, for the same reason as PartialThermoInterface: this
     class is reached twice when the two halves are mixed, and Modelica
     duplicates inherited equations while merging inherited declarations.
     --------------------------------------------------------------------- */

  extends Simulator.GuessModels.InitialGuess;

  //--- Reaction definition: specified by the user, read by both halves ---
  parameter Integer Nr "Number of reactions";
  parameter Real Coef_cr[Nc, Nr] "Stoichiometric coefficient of each component in each reaction";

  /* Base component of each reaction. Deliberately a variable rather than a
     parameter: the conversion, kinetic and PFR reactors take it as a plain
     specification (BC_r = {1}), but EquilibriumReactor derives it at run time
     from the feed via ReactionManager.BaseCalc. A variable supports both --
     a modification supplies it as a declaration equation where it is a
     specification, and an ordinary equation supplies it where it is
     computed. */
  Integer BC_r[Nr] "Base component of each reaction";

  //--- Computed by the reaction half, consumed by the reactor half ---
  Real Schk_r[Nr] "Stoichiometry check per reaction";
  Real Hf_c[Nc] "Heat of formation per component";
  Real Hr_r[Nr] "Heat of reaction per reaction";

end PartialReactionInterface;
