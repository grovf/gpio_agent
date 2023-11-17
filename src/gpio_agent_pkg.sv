/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent package. Contains :
 *                 - User specified input and output pins
 *                 - User specified initial output signal values
 *                 - All needed files for building the GPIO agent (except the GPIO interface)
 *                 - Convenience functions/tasks for writing/reading pin values

 *               GPIO agent inputs  == DUT outputs
 *               GPIO agent outputs == DUT inputs
*
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *
 * UPDATES     :
 *               1. Remove methods from package (2023, Valerii Dzhafarov)
 *               2. Add config usage, resolve type names through forward class declaration (2023, Valerii Dzhafarov)
 */

`ifndef _AGENT_GPIO_PKG_
`define _AGENT_GPIO_PKG_

package GpioAgentPkg;

//==============================================================================
// System section
//==============================================================================

//******************************************************************************
// Constants, classes, types, etc.
//******************************************************************************

  typedef enum {
    RD_SYNC,
    RD_ASYNC,
    WR_SYNC,
    WR_ASYNC,
    WR_WIN_SYNC,
    WR_WIN_ASYNC
  } op_type_t;

//******************************************************************************
// Imports
//******************************************************************************

  import uvm_pkg::*;

//******************************************************************************
// Includes
//******************************************************************************

  `include "uvm_macros.svh"

  typedef class GpioAgentCfg;
  typedef class GpioAgentSequencer;
  // sequences
  `include "sequences/gpio_item.svh"
  `include "sequences/gpio_base_sequence.svh"
  `include "sequences/gpio_set_pin_sequence.svh"
  `include "sequences/gpio_get_pin_sequence.svh"

  // components
  `include "agent/gpio_agent_cfg.svh"
  `include "agent/gpio_sequencer.svh"
  `include "agent/gpio_driver.svh"
  `include "agent/gpio_monitor.svh"
  `include "agent/gpio_agent.svh"

endpackage : GpioAgentPkg

`endif
