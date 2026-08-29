within Simulator.GuessModels;

partial model GuessInput
  parameter Integer Nc "Number of components";
  parameter Simulator.Files.ChemsepDatabase.GeneralProperties C[Nc] "Component instances array";
  parameter Real Pg = 101325;
  parameter Real Fg =  60;  
end GuessInput;
