package MyModels
  
  model MyFirstStream "First material stream: Ethanol-Water, TP flash"
    import data = Simulator.Files.ChemsepDatabase;
    parameter data.Ethanol eth;
    parameter data.Water wat;
    extends Simulator.Streams.MaterialStream(Nc = 2, C = {eth, wat});
    extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;
  equation
    P = 101325;              // 1 atm, in Pa
    T = 350;                 // Kelvin
    x_pc[1, :] = {0.4, 0.6}; // mole fraction: 40% ethanol, 60% water
    F_p[1] = 100;            // mol/s total molar flow
  end MyFirstStream;
end MyModels;
