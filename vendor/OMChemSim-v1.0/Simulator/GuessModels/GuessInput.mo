within Simulator.GuessModels;

partial model GuessInput
  "User-supplied anchors for start-value generation"
  parameter Integer Nc "Number of components";
  parameter Simulator.Files.ChemsepDatabase.GeneralProperties C[Nc] "Component instances array";
  parameter Real Pg = 101325 "Guess pressure, Pa";
  parameter Real Fg = 60 "Guess molar flow, mol/s";

  /* Optional temperature anchor. Left at 0, InitialGuess derives the guess
     temperature from the component set, as the midpoint of the mixture's
     bubble and dew temperatures at Pg.

     That derivation assumes every component can condense. It breaks down for a
     mixture containing a permanent gas: air's vapour-pressure correlation
     extrapolated to 1 atm crosses at 78.6 K, so an acetone/air/water absorber
     gets a bubble temperature of 90 K and a guess of about 220 K, while the
     column actually operates near 330 K -- far enough off that the solver can
     diverge. There is no reliable way to identify a non-condensable from the
     component data alone (the test would have to know the operating
     temperature, which is what is being guessed), so rather than apply a
     heuristic that misfires on genuine low-temperature VLE, set this
     explicitly on such models:

         MyColumn B1(Nc = Nc, C = C, Tg_user = 330);

     Only affects start values; it cannot change the converged solution. */
  parameter Real Tg_user = 0 "Temperature guess, K; 0 = derive from the component set";

  /* Optional composition anchor, same idea as Tg_user. Left at zeros,
     InitialGuess assumes an equimolar feed, which is the neutral choice when
     nothing is known. Set it when the real composition is far from equimolar
     -- a dilute absorber, a near-pure solvent -- and the equimolar flash
     seeds the solver badly. Need not be normalised. */
  parameter Real xg_user[Nc] = zeros(Nc) "Composition guess; all zeros = assume equimolar";
end GuessInput;
