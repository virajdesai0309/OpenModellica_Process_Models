within Simulator.Files;

package Types "Enumerations used to select a unit operation's calculation mode"
  extends Modelica.Icons.TypesPackage;

  /* NOT IN UPSTREAM v1.0 (see ATTRIBUTION.md).

     Upstream leaves each unit operation one degree of freedom short and expects
     the flowsheet to close it with a hand-written equation, e.g.

         B1.Pdel = 101325;

     That works, but it is invisible in OMEdit: a user who drags a pump onto the
     canvas and opens its parameter dialog is told the efficiency and nothing
     else, and gets "Too few equations" if they do not know to go and type an
     equation somewhere. The enumerations here name the available closures so
     that the choice becomes a dropdown on the block itself, the way a process
     simulator presents it.

     One enumeration per unit operation rather than one shared one, because the
     closures differ: a pump can be specified on pressure or power, a heater on
     temperature, duty or vapour fraction. They live together here so that a
     model needing one does not have to reach into another unit operation's
     namespace. */

end Types;
