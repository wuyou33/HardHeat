create_clock -period 10us -name adpll_ref [get_ports ref_in]
create_clock -period 100MHz -name 100MHzClk [get_ports clk_in]
set_false_path -from [get_ports sig_in]
set_false_path -to [get_ports sig_lh_out]
set_false_path -to [get_ports sig_ll_out]
set_false_path -to [get_ports sig_rh_out]
set_false_path -to [get_ports sig_rl_out]
derive_pll_clocks
