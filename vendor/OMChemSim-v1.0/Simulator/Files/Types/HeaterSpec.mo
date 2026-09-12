within Simulator.Files.Types;

type HeaterSpec = enumeration(
    FlowsheetEquation "Specified by an equation in the flowsheet (default)",
    OutletTemperature "Specified outlet temperature",
    TemperatureIncrease "Specified temperature increase",
    HeatAdded "Specified heat duty",
    OutletVaporFraction "Specified outlet vapour fraction")
  "How the remaining degree of freedom of a heater is closed"
  annotation(
    Documentation(info = "<html><head></head><body><div>A heater's pressure drop and efficiency are already parameters. What is left unspecified is its thermal duty, and this enumeration names the ways of fixing it.</div><div><br></div><ul><li><b>FlowsheetEquation</b> &mdash; the model contributes no closing equation, and the flowsheet must supply one, e.g. <code>B1.Q = 2000000;</code>. This is the upstream behaviour and the default, so existing models are unaffected.</li><li><b>OutletTemperature</b> &mdash; heat until the stream reaches <code>Tout_spec</code>.</li><li><b>TemperatureIncrease</b> &mdash; raise the stream by <code>Tdel_spec</code>.</li><li><b>HeatAdded</b> &mdash; add <code>Q_spec</code> watts; the temperature rise follows.</li><li><b>OutletVaporFraction</b> &mdash; heat until the outlet reaches a vapour fraction of <code>xvapout_spec</code>. Use this to boil a stream to a known quality rather than to a known temperature.</li></ul><div><br></div><div>Selecting any mode other than <b>FlowsheetEquation</b> means the flowsheet must <i>not</i> also specify the duty, or the model is over-determined.</div></body></html>"));
