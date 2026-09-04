model SimpleRamp
  Real output_value;   // A variable to hold our result
  parameter Real slope = 2.0; // A user-defined parameter
equation
  output_value = slope * time; // 'time' is a built-in simulation variable
end SimpleRamp;
