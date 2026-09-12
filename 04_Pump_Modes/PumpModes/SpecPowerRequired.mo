within PumpModes;

model SpecPowerRequired "Duty set by the pump's specified shaft power"
  extends Modelica.Icons.Example;
  /* 961.6676259982341 W is what the other three models draw at 398675 Pa. It is
     given here to five more digits than anyone would type so that this model
     reproduces them to round-off, which is what makes the comparison a test.

     This is the one mode that runs the energy balance backwards: given only the
     shaft power it has to recover the pressure rise, via
     Q = Fin*(Hout - Hin) and Hout = Hin + Pdel/(rho*Eff). It therefore agrees
     with the other three only because that balance keeps the friction heat in
     the fluid -- against the upstream form, which divided by Eff a second time,
     this model would come back 25% off. See ATTRIBUTION.md section 7. */
  extends PumpModes.PumpFlowsheet(
    B1(spec = Simulator.Files.Types.PumpSpec.PowerRequired, Q_spec = 961.6676259982341));

  annotation(
    Documentation(info = "<html><head></head><body><div>The pump is given a specified <b>shaft power</b> of 961.6676 W and works out the pressure rise it buys, rather than the other way round. Set on the block itself under <b>Pump Specifications &rarr; Calculation Mode</b>; the flowsheet writes no duty equation.</div><div><br></div><div>The power quoted is what the other three models in this package draw, so this one should reproduce their 398675 Pa rise, 500000 Pa outlet and 300.1289 K discharge temperature.</div><div><br></div><div>This is the mode that inverts the energy balance, so it is the one that would break first if that balance were wrong.</div></body></html>"),
    experiment(StopTime = 1, Interval = 1));
end SpecPowerRequired;
