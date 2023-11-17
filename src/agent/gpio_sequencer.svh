/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO sequencer
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *               Nazar Zibilyuk
 *
 * UPDATES     :
 *               1. Add config and it's use in run phase (2023, Valerii Dzhafarov)
 *               2. Stylistic changes (2023, Nazar Zibilyuk)
 */

class GpioAgentSequencer extends uvm_sequencer #(GpioItem);
  `uvm_component_utils(GpioAgentSequencer)
  
  GpioAgentCfg              cfg;

  // Methods
  function new(string name = "GpioAgentSequencer", uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  extern virtual function void handle_reset(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void check_cfg();
  
endclass : GpioAgentSequencer

//------------------------------------------------------------------------------

  function void GpioAgentSequencer::handle_reset(uvm_phase phase);
    uvm_objection objection = phase.get_objection();
    int objection_cnt;
    
    stop_sequences();
    
    objection_cnt = objection.get_objection_count(this);
    
    if (objection_cnt > 0) begin
      objection.drop_objection(this, $sformatf("Dropping %0d objections at reset", objection_cnt), objection_cnt);
    end
    
    start_phase_sequence(phase);
  endfunction : handle_reset

  task GpioAgentSequencer::run_phase(uvm_phase phase);
    check_cfg();
    super.run_phase(phase);
  endtask
  
  function void GpioAgentSequencer::check_cfg();
    if (cfg == null) begin
      `uvm_fatal("GPIO_AGT", "Couldn't get the GPIO agent configuration")
    end
  endfunction: check_cfg

