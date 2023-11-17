/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent sequence used to write bit values to selected design
 *               input pins.
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *               Nazar Zibilyuk
 *
 * UPDATES     :
 *               1. Rewrite to use configurtion and new naming (2023, Valerii Dzhafarov)
 *               2. Stylistic changes (2023, Nazar Zibilyuk)
 */

class GpioSetPinSequence extends GpioBaseSequence;
  `uvm_object_utils(GpioSetPinSequence)

  // Constructor
  function new(string name = "GpioSetPinSequence");
    super.new(name);
  endfunction: new

  // Function/Task declarations
  extern virtual task body();

endclass: GpioSetPinSequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task GpioSetPinSequence::body();

    super.body(); // create the transaction item
    start_item(it);

    if (!it.randomize() with {
      gpio_out.size()   == local::gpio_out.size();
      foreach(local::gpio_out[i]) {
        gpio_out[i]     == local::gpio_out[i];
      }
      op_type           == local::op_type;
      delay             == local::delay;
    }
    ) begin
      `uvm_error("GPIO_SET_SQNC", "\nRandomization failed\n")
    end

    finish_item(it);

  endtask: body
