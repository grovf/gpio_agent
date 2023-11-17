/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent base sequence. All other sequences are extended from
 *               this one.
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *               Nazar Zibilyuk
 *
 * UPDATES     :
 *               1. Rewrite to use configurtion, add safety checks (2023, Valerii Dzhafarov)
 *               2. Stylistic changes (2023, Nazar Zibilyuk)
 */

class GpioBaseSequence extends uvm_sequence #(GpioItem);
  `uvm_object_utils(GpioBaseSequence)

  // Variables
  GpioItem             it, rsp;   // item and response
  static int           inst_cnt;  // current instance number

         logic         gpio_in    [];
  rand   logic         gpio_out   [];

  rand   bit [31:0]    delay;
  rand   op_type_t     op_type;

  protected GpioAgentCfg         cfg;

  // Constructor
  function new(string name = "GpioBaseSequence");
    super.new(name);
  endfunction: new

  extern virtual task body();

endclass: GpioBaseSequence

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task GpioBaseSequence::body();
    GpioAgentSequencer   sqcr;

    if (!$cast(sqcr, m_sequencer)) begin
      `uvm_fatal("SQR_TYPE", "Sequencer type mismatch")
    end

    cfg = sqcr.cfg;

    inst_cnt++;
    it = GpioItem::type_id::create("gpio_it");

    if (gpio_out.size() > cfg.width_o) begin
      `uvm_warning("GPIO_WDTH", $sformatf("GPIO Width in seq = %d more than in cfg = %d. MSB will be truncated",gpio_out.size(),cfg.width_o))
    end

  endtask: body
