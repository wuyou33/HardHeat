onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pwm_tb/DUT_inst/reset
add wave -noupdate /pwm_tb/DUT_inst/clk
add wave -noupdate /pwm_tb/DUT_inst/enable_in
add wave -noupdate -format Analog-Step -height 88 -max 4095.0 -radix unsigned /pwm_tb/DUT_inst/mod_lvl_in
add wave -noupdate /pwm_tb/DUT_inst/mod_lvl_f_in
add wave -noupdate /pwm_tb/DUT_inst/pwm_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4113479911 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 287
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
configure wave -timelineunits us
update
WaveRestoreZoom {3606853020 ps} {4733023644 ps}
