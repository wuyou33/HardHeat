create_clock -period 10us -name adpll_ref [get_ports ref_in]
create_clock -period 50MHz -name 50MHzClk [get_ports clk_in]
set_false_path -from [get_ports reset_in]
set_false_path -from [get_ports sig_in]
set_false_path -from [get_ports ow_in]
set_false_path -from [get_ports mod_lvl_in*]
set_false_path -to [get_ports ow_out]
set_false_path -to [get_ports sig_lh_out]
set_false_path -to [get_ports sig_ll_out]
set_false_path -to [get_ports sig_rh_out]
set_false_path -to [get_ports sig_rl_out]
set_false_path -to [get_ports lock_out]
set_false_path -to [get_ports pwm_out]
set_false_path -to [get_ports temp_err_out]
set_false_path -to [get_ports ow_pullup_out]
derive_pll_clocks

# JTAG signal constraints, needed for SignalTap
# Constrain the TCK port
create_clock \
-name tck \
-period "10MHz" \
-add \
[get_ports altera_reserved_tck]

# Cut all paths to and from tck
set_clock_groups -exclusive -group [get_clocks tck]

# TDI port
set_input_delay \
-clock tck \
20 \
[get_ports altera_reserved_tdi]

# TMS port
set_input_delay \
-clock tck \
20 \
[get_ports altera_reserved_tms]

# TDO port
set_output_delay \
-clock tck \
20 \
[get_ports altera_reserved_tdo]
