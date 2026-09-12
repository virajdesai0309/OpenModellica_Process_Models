within Simulator.Files.Types;

type ValveSpec = enumeration(
    FlowsheetEquation "Specified by an equation in the flowsheet (default)",
    OutletPressure "Specified outlet pressure",
    PressureDrop "Specified pressure drop")
  "How the remaining degree of freedom of a valve is closed"
  annotation(
    Documentation(info = "<html><head></head><body><div>A valve is isenthalpic and carries no efficiency, so its only specification is how far it lets the pressure fall.</div><div><br></div><ul><li><b>FlowsheetEquation</b> &mdash; the model contributes no closing equation, and the flowsheet must supply one, e.g. <code>B1.Pdel = 101325;</code>. This is the upstream behaviour and the default, so existing models are unaffected.</li><li><b>OutletPressure</b> &mdash; the valve lets the stream down to <code>Pout_spec</code>.</li><li><b>PressureDrop</b> &mdash; the valve drops <code>Pdel_spec</code> from the inlet pressure.</li></ul><div><br></div><div>There is no duty mode: the valve carries <code>Hin = Hout</code> and has no energy connector.</div><div><br></div><div>Selecting any mode other than <b>FlowsheetEquation</b> means the flowsheet must <i>not</i> also specify the duty, or the model is over-determined.</div></body></html>"));
