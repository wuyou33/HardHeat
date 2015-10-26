onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /epdm_tb/DUT_inst/reset
add wave -noupdate /epdm_tb/DUT_inst/clk
add wave -noupdate -radix unsigned /epdm_tb/DUT_inst/mod_lvl_in
add wave -noupdate /epdm_tb/DUT_inst/mod_lvl_in_f
add wave -noupdate /epdm_tb/DUT_inst/sig_in
add wave -noupdate /epdm_tb/DUT_inst/sig_lh_out
add wave -noupdate /epdm_tb/DUT_inst/sig_ll_out
add wave -noupdate /epdm_tb/DUT_inst/sig_rl_out
add wave -noupdate /epdm_tb/DUT_inst/sig_rh_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {109765123 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 288
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {672631955 ps} {1017229897 ps}
