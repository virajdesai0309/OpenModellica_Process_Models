within Simulator.Files.Types;

type ExpanderSpec = enumeration(
    FlowsheetEquation "Specified by an equation in the flowsheet (default)",
    OutletPressure "Specified outlet pressure",
    PressureDrop "Specified pressure drop",
    ShaftPower "Specified shaft power (negative)")
  "How the remaining degree of freedom of an adiabatic expander is closed"
  annotation(
    Documentation(info = "<html><head></head><body><div>An adiabatic expander carries one degree of freedom beyond its efficiency: how far it is allowed to let the stream down. This enumeration names the ways of closing it.</div><div><br></div><ul><li><b>FlowsheetEquation</b> &mdash; the model contributes no closing equation, and the flowsheet must supply one, e.g. <code>B1.Pdel = 10000;</code>. This is the upstream behaviour and the default, so existing models are unaffected.</li><li><b>OutletPressure</b> &mdash; the expander lets the stream down to <code>Pout_spec</code>.</li><li><b>PressureDrop</b> &mdash; the expander drops <code>Pdel_spec</code> from the inlet pressure (<code>Pin - Pdel = Pout</code>).</li><li><b>ShaftPower</b> &mdash; the shaft carries <code>Q_spec</code> watts, and the pressure drop follows from it.</li></ul><div><br></div><div><b>Note the sign.</b> The expander writes <code>Q = Fin*(H_p[1] - Hin)*Eff</code>, and the stream gives up enthalpy, so <code>Q</code> is <b>negative</b> &mdash; the shipped Expander example returns -12387.9 W. <code>Q_spec</code> is that same quantity and must be given negative; the mode sets <code>Q = Q_spec</code> with no sign flip, so what is typed is what appears in the results.</div><div><br></div><div>Selecting any mode other than <b>FlowsheetEquation</b> means the flowsheet must <i>not</i> also specify the duty, or the model is over-determined.</div></body></html>"));
