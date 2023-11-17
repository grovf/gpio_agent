/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent monitor. Used for recording DUT pins on every clock
 *               cycle and sending that information through the analysis port.
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *               Nazar Zibilyuk
 *
 * UPDATES     :
 *               1. Make use of config (2023, Valerii Dzhafarov)
 *               2. Stylistic changes (2023, Nazar Zibilyuk)
 */

class GpioMonitor extends uvm_monitor;
  `uvm_component_utils(GpioMonitor)

  // Components
  virtual GpioIf.mp_monitor     mp;

  // Configurations
  GpioAgentCfg cfg;

  // Ports
  uvm_analysis_port #(GpioItem) aport;

  // Constructor
  function new(string name = "GpioMonitor", uvm_component parent);
    super.new(name, parent);
    aport = new("aport", this);
  endfunction

  // Function/Task declarations
  extern virtual function void checkXZ  (GpioItem it);
  extern virtual task          run_phase(uvm_phase phase);
  extern virtual task          readPins (GpioItem it);
  
  extern virtual function void get_config();

endclass: GpioMonitor

//******************************************************************************
// Function/Task implementations
//******************************************************************************

  function void GpioMonitor::checkXZ(input GpioItem it);
    string warn_string_x;
    string warn_string_z;

    for (int i = 0; i < cfg.width_i; i++) begin
      if          (it.gpio_in[i] === 1'bX) begin
        warn_string_x = $sformatf({warn_string_x, " %s"}, cfg.pin_name_i[i]);
      end else if (it.gpio_in[i] === 1'bZ) begin
        warn_string_z = $sformatf({warn_string_z, " %s"}, cfg.pin_name_i[i]);
      end
    end

    for (int i = 0; i < cfg.width_o; i++) begin
      if          (it.gpio_out[i] === 1'bX) begin
        warn_string_z = $sformatf({warn_string_z, " %s"}, cfg.pin_name_o[i]);
      end else if (it.gpio_out[i] === 1'bZ) begin
        warn_string_z = $sformatf({warn_string_z, " %s"}, cfg.pin_name_o[i]);
      end
    end

    if          (warn_string_x != "") begin
      `uvm_warning("GPIO_MON", {"Value 'X' detected on pin(s) :", warn_string_x})
    end else if (warn_string_z != "") begin
      `uvm_warning("GPIO_MON", {"Value 'Z' detected on pin(s) :", warn_string_z})
    end
  endfunction : checkXZ

  //----------------------------------------------------------------------------

  task GpioMonitor::readPins(input GpioItem it);
    @mp.cb_monitor;

    for (int i = 0; i < cfg.width_i; i++) begin
      it.gpio_in[i]  = mp.cb_monitor.gpio_in[i];
    end

    for (int i = 0; i < cfg.width_o; i++) begin
      it.gpio_out[i] = mp.cb_monitor.gpio_out[i];
    end
  endtask: readPins

  function void GpioMonitor::get_config();
    if (cfg == null) begin
      `uvm_fatal("GPIO_AGT", "Couldn't get the GPIO agent configuration")
    end
  endfunction: get_config


  //----------------------------------------------------------------------------

  task GpioMonitor::run_phase(uvm_phase phase);
    GpioItem it;
    it          = GpioItem::type_id::create("it_mon");
    it.gpio_in  = new [cfg.width_i];
    it.gpio_out = new [cfg.width_o];

    forever begin
    
      @(negedge mp.rst);
      fork
        forever begin
          readPins(it);

          // perform checking for 'X' and 'Z' values
          if (cfg.is_x_z_check) begin
            checkXZ(it);
          end
      
          aport.write(GpioItem'(it.clone()));
        end
      join_none
      
      @(posedge mp.rst);
      disable fork;
      
    end
  endtask: run_phase
