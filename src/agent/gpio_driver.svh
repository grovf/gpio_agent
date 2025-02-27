/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent driver. Used for translating sequence items into pin
 *               wiggles.
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *               Nazar Zibilyuk
 *
 * UPDATES     :
 *               1. Add using and checkint config (2023, Valerii Dzhafarov)
 *               2. Improve naming (2023, Valerii Dzhafarov)
 *               3. Stylistic changes (2023, Nazar Zibilyuk)
 */

class GpioDriver extends uvm_driver #(GpioItem);
  `uvm_component_utils(GpioDriver)

  // Components
  virtual GpioIf            vif;
  virtual GpioIf.mp_master  mp_mas;
  virtual GpioIf.mp_monitor mp_mon;

  GpioAgentCfg              cfg;
  // Constructor
  function new(string name = "GpioDriver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Function/Task declarations
  extern virtual task driveInit     ();
  extern virtual task driveGpioPins (input GpioItem it, input bit is_sync);
  extern virtual task driveGpioPinsW(input GpioItem it, input bit is_sync);
  extern virtual task readGpioPins  (input GpioItem it, output GpioItem rsp, input bit is_sync);
  extern virtual task run_phase     (uvm_phase phase);

  extern virtual function void check_cfg();
endclass: GpioDriver

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  task GpioDriver::driveInit();
    @mp_mas.cb_master;
    mp_mas.cb_master.gpio_out <= cfg.gpio_out_init;
  endtask: driveInit

  //----------------------------------------------------------------------------

  task GpioDriver::driveGpioPins(input GpioItem it, input bit is_sync);
    // wait for clock only if synchronous write
    if (is_sync) begin
      @mp_mas.cb_master;
    end

    foreach (it.gpio_out[i]) begin
      if (is_sync) begin
        mp_mas.cb_master.gpio_out[i] <= it.gpio_out[i];
      end else begin
        vif.gpio_out[i]              <= it.gpio_out[i];
      end
    end
  endtask: driveGpioPins

  //----------------------------------------------------------------------------

  task GpioDriver::driveGpioPinsW(input GpioItem it, input bit is_sync);
    if (is_sync) begin
      @mp_mas.cb_master;
      // add delay
      repeat (it.delay) begin
        @mp_mas.cb_master;
      end
    end else begin
      #(it.delay * 1ns);
    end

    foreach (it.gpio_out[i]) begin
      if (is_sync) begin
        mp_mas.cb_master.gpio_out[i] <= it.gpio_out[i];
      end else begin
        vif.gpio_out[i]              <= it.gpio_out[i];
      end
    end
  endtask: driveGpioPinsW

  //----------------------------------------------------------------------------

  task GpioDriver::readGpioPins(input GpioItem it, output GpioItem rsp, input bit is_sync);
    rsp = GpioItem::type_id::create("rsp");
    rsp.gpio_in  = new [cfg.width_i];
    rsp.gpio_out = new [cfg.width_o];

    // wait for clock only if synchronous read
    if (is_sync) begin
      @mp_mon.cb_monitor;
    end

    foreach (rsp.gpio_in[i]) begin
      if (is_sync) begin
        rsp.gpio_in[i] = mp_mon.cb_monitor.gpio_in[i];
      end else begin
        rsp.gpio_in[i] = vif.gpio_in[i];
      end
    end

    foreach (rsp.gpio_out[i]) begin
      if (is_sync) begin
        rsp.gpio_out[i] = mp_mon.cb_monitor.gpio_out[i];
      end else begin
        rsp.gpio_out[i] = vif.gpio_out[i];
      end
    end

    rsp.set_id_info(it);
  endtask: readGpioPins

  function void GpioDriver::check_cfg();
    if (cfg == null) begin
      `uvm_fatal("GPIO_AGT", "Couldn't get the GPIO agent configuration")
    end
  endfunction: check_cfg


  //----------------------------------------------------------------------------

  task GpioDriver::run_phase(uvm_phase phase);
    GpioItem it, rsp;

    check_cfg();
    driveInit();
    forever begin
      
      @(negedge vif.rst);
      fork
        forever begin
          rsp = null;
          seq_item_port.get_next_item(it);

          case(it.op_type)
            RD_SYNC      : readGpioPins  (it, rsp, 1'b1);
            RD_ASYNC     : readGpioPins  (it, rsp, 1'b0);
            WR_SYNC      : driveGpioPins (it, 1'b1);
            WR_ASYNC     : driveGpioPins (it, 1'b0);
            WR_WIN_SYNC  : driveGpioPinsW(it, 1'b1);
            WR_WIN_ASYNC : driveGpioPinsW(it, 1'b0);
            default      : `uvm_error("GPIO_DRV", "No such operation")
          endcase

          // get next transaction on rising clk edge
          // @mp.cb_master;
          if (rsp == null) begin
            `uvm_info("GPIO_DRV", "Processed Set Pin OP", UVM_HIGH)
            seq_item_port.item_done();
          end else begin
            `uvm_info("GPIO_DRV", "Processed Get Pin OP", UVM_HIGH)
             seq_item_port.item_done(rsp);
          end
        end
      join_none
      
      @(posedge vif.rst);
      disable fork;
      driveInit();
        
    end
  endtask: run_phase
