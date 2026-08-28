model Example_One
  "Dummy model used to learn the OMEdit workflow: draws a square with a cross as its icon"

  parameter Real a = 1 "Decay constant, used only to exercise simulation";
  Real x(start = 1, fixed = true) "Dummy state variable with no physical meaning";

equation
  der(x) = -a * x;

  annotation(
    Icon(graphics = {
      Rectangle(extent = {{-100, -100}, {100, 100}}, lineColor = {0, 0, 0}, lineThickness = 0.5),
      Line(points = {{-100, -100}, {100, 100}}, color = {0, 0, 0}),
      Line(points = {{-100, 100}, {100, -100}}, color = {0, 0, 0})
    }),
    Diagram(graphics = {
      Rectangle(extent = {{-100, -100}, {100, 100}}, lineColor = {0, 0, 0}),
      Line(points = {{-100, -100}, {100, 100}}, color = {0, 0, 0}),
      Line(points = {{-100, 100}, {100, -100}}, color = {0, 0, 0})
    }),
    Documentation(info = "<html><p>Dummy model created while learning the OMEdit workflow. The icon is a square with a cross, drawn using basic graphical primitives. A single dummy state variable x with first-order decay dynamics (der(x) = -a*x) is included so the model can be checked, translated, and simulated end-to-end.</p></html>"),
    experiment(StartTime = 0, StopTime = 10, Tolerance = 1e-6, Interval = 0.02));
end Example_One;
