within PumpModes;

model WaterStream "Material stream closed with Raoult's law"
  /* A MaterialStream is not simulatable on its own: it needs a thermodynamic
     package mixed in alongside it to supply K-values and residual properties.
     Both extends clauses are left unmodified and Nc/C are specified where this
     model is instantiated -- see the diamond note in PartialThermoInterface.mo,
     which explains why a modification on only one of them is rejected. */
  extends Simulator.Streams.MaterialStream;
  extends Simulator.Files.ThermodynamicPackages.RaoultsLaw;
  annotation(
    Documentation(info = "<html><head></head><body>A <a href=\"modelica://Simulator.Streams.MaterialStream\">MaterialStream</a> combined with <a href=\"modelica://Simulator.Files.ThermodynamicPackages.RaoultsLaw\">Raoult's law</a>, so that it can be instantiated. Raoult's law is adequate here because the streams carry a single component, for which the activity and fugacity corrections a real package would add cancel out of the K-value entirely.</body></html>"));
end WaterStream;
