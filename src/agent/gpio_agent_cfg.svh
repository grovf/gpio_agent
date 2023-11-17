/* AUTHOR      : Ivan Mokanj
 * START DATE  : 2017
 * LICENSE     : LGPLv3
 *
 * DESCRIPTION : GPIO agent configuration class. An object of this class should
 *               be put in the configuration database so that the GPIO agent can
 *               get the user configuration.
 *
 * CONTRIBUTORS:
 *               Valerii Dzhafarov
 *               Nazar Zibilyuk
 *
 * UPDATES     :
 *               1. Extend config to include pin names, width and initialization (2023, Valerii Dzhafarov)
 *               2. Add methods to set agent width, change default setting for agent to be active (2023, Valerii Dzhafarov)
 *               3. Stylistic changes. Restore original coding style (2023, Nazar Zibilyuk)
 *
 */

class GpioAgentCfg extends uvm_object;
  `uvm_object_utils(GpioAgentCfg)

  // Variables
  uvm_active_passive_enum is_active    = UVM_ACTIVE;
  bit                     is_x_z_check = 1'b0;
  int                     width_i;
  int                     width_o;
  string                  pin_name_i [];
  string                  pin_name_o [];
  bit [1023:0]            gpio_out_init;

  virtual GpioIf          vif;


  // Constructor
  function new(string name = "GpioAgentCfg");
    super.new(name);
  endfunction


  virtual function int set_widths(int _width_i, _width_o);
    width_i = _width_i;
    width_o = _width_o;

    pin_name_i = new[width_i];
    pin_name_o = new[width_o];
    
    for (int i=0; i<_width_i; i++)  begin
      pin_name_i[i] = $sformatf("i_pin_%0d", i);
    end

    for (int i=0; i<_width_o; i++) begin
      pin_name_o[i] = $sformatf("o_pin_%0d", i);
    end
      
  endfunction: set_widths


endclass: GpioAgentCfg
