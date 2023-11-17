/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent sequence item.
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 * UPDATES     :
 *               1. Remove using pin name, now names are in the config (2023, Valerii Dzhafarov)
 */

class GpioItem extends uvm_sequence_item;

  // Variables
  rand op_type_t     op_type;
  rand   bit [31:0]  delay;

       logic         gpio_in    [];
  rand logic         gpio_out   [];

  // Constructor
  function new(string name = "GpioItem");
    super.new(name);
  endfunction

  `uvm_object_utils_begin(GpioItem)
    `uvm_field_enum      (   op_type_t,     op_type, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_int       (                    delay, UVM_DEFAULT | UVM_NOPACK)
    `uvm_field_array_int (                  gpio_in, UVM_DEFAULT | UVM_NOPACK | UVM_NOPRINT)
    `uvm_field_array_int (                 gpio_out, UVM_DEFAULT | UVM_NOPACK | UVM_NOPRINT)
  `uvm_object_utils_end

endclass: GpioItem
