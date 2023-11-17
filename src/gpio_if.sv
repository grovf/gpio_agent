/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent interface signal definitions. Interface is connected
 *               to the DUT and used by the GPIO agent to read/write pins.
 *
 *               GPIO agent inputs  == DUT outputs
 *               GPIO agent outputs == DUT inputs
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *               Nazar Zibilyuk
 *
 * UPDATES     :
 *               1. Add skew and clocking blocks (2023, Valerii Dzhafarov)
 *               2. Add width parameterization (2023, Nazar Zibilyuk)
 */

`ifndef GPIO_CLOCKING_IN_SKEW
  `define GPIO_CLOCKING_IN_SKEW #1step
`endif

`ifndef GPIO_CLOCKING_OUT_SKEW
  `define GPIO_CLOCKING_OUT_SKEW #0
`endif

interface GpioIf #(
  parameter INPUT_NUM  = 1024,
  parameter OUTPUT_NUM = 1024
)(
  input logic clk,
  input logic rst
);

//******************************************************************************
// Ports
//******************************************************************************

  wire  [ INPUT_NUM - 1:0] gpio_in;
  logic [OUTPUT_NUM - 1:0] gpio_out;

//******************************************************************************
// Clocking Blocks
//******************************************************************************

  // GPIO Master clocking block
  clocking cb_master @(posedge clk);
    default input `GPIO_CLOCKING_IN_SKEW output `GPIO_CLOCKING_OUT_SKEW;
    input  gpio_in;
    output gpio_out;
  endclocking

  // GPIO Monitor clocking block
  clocking cb_monitor @(posedge clk);
    default input `GPIO_CLOCKING_IN_SKEW;
    input  gpio_in, gpio_out;
  endclocking

//******************************************************************************
// Modports
//******************************************************************************

  // GPIO Master modport
  modport mp_master (input clk, input rst, clocking cb_master);

  // GPIO Monitor modport
  modport mp_monitor(input clk, input rst, clocking cb_monitor);

endinterface : GpioIf
