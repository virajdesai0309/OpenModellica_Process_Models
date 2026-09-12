within Simulator.Files.Types;

type CoolerSpec = enumeration(
    FlowsheetEquation "Specified by an equation in the flowsheet (default)",
    OutletTemperature "Specified outlet temperature",
    TemperatureDrop "Specified temperature drop",
    HeatRemoved "Specified heat duty",
    OutletVaporFraction "Specified outlet vapour fraction")
  "How the remaining degree of freedom of a cooler is closed"
  annotation(
    Documentation(info = "<html><head></head><body><div>A cooler's pressure drop and efficiency are already parameters. What is left unspecified is its thermal duty, and this enumeration names the ways of fixing it.</div><div><br></div><ul><li><b>FlowsheetEquation</b> &mdash; the model contributes no closing equation, and the flowsheet must supply one, e.g. <code>B1.Q = 200000;</code>. This is the upstream behaviour and the default, so existing models are unaffected.</li><li><b>OutletTemperature</b> &mdash; cool until the stream reaches <code>Tout_spec</code>.</li><li><b>TemperatureDrop</b> &mdash; lower the stream by <code>Tdel_spec</code>.</li><li><b>HeatRemoved</b> &mdash; remove <code>Q_spec</code> watts; the temperature drop follows.</li><li><b>OutletVaporFraction</b> &mdash; cool until the outlet reaches a vapour fraction of <code>xvapout_spec</code>. Use this to condense a stream to a known quality rather than to a known temperature.</li></ul><div><br></div><div><b>Sign convention.</b> A <b>positive</b> <code>Q</code> is heat <i>removed</i> and a positive <code>Tdel</code> is a temperature <i>drop</i>: the model carries <code>Hin - Eff*Q/Fin = Hout</code> and <code>Tin - Tdel = Tout</code>.</div><div><br></div><div>Selecting any mode other than <b>FlowsheetEquation</b> means the flowsheet must <i>not</i> also specify the duty, or the model is over-determined.</div></body></html>"));
