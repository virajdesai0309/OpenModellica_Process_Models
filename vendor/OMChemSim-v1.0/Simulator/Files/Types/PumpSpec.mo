within Simulator.Files.Types;

type PumpSpec = enumeration(
    FlowsheetEquation "Specified by an equation in the flowsheet (default)",
    OutletPressure "Specified outlet pressure",
    PressureIncrease "Specified pressure increase",
    PowerRequired "Specified shaft power")
  "How the remaining degree of freedom of a centrifugal pump is closed"
  annotation(
    Documentation(info = "<html><head></head><body><div>A centrifugal pump carries one degree of freedom beyond its efficiency: the duty it is asked to deliver. This enumeration names the ways of closing it.</div><div><br></div><ul><li><b>FlowsheetEquation</b> — the model contributes no closing equation, and the flowsheet must supply one, e.g. <code>B1.Pdel = 101325;</code>. This is the upstream behaviour and the default, so existing models are unaffected.</li><li><b>OutletPressure</b> — the pump raises the stream to <code>Pout_spec</code>.</li><li><b>PressureIncrease</b> — the pump adds <code>Pdel_spec</code> to the inlet pressure.</li><li><b>PowerRequired</b> — the shaft delivers <code>Q_spec</code>, and the pressure rise follows from it.</li></ul><div><br></div><div>Selecting any mode other than <b>FlowsheetEquation</b> means the flowsheet must <i>not</i> also specify the duty, or the model is over-determined.</div></body></html>"));
