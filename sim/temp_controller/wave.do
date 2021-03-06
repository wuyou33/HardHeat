onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /temp_controller_tb/DUT_inst/reset
add wave -noupdate /temp_controller_tb/DUT_inst/clk
add wave -noupdate /temp_controller_tb/DUT_inst/enable_in
add wave -noupdate /temp_controller_tb/DUT_inst/temp_out_f
add wave -noupdate /temp_controller_tb/DUT_inst/pwm_out
add wave -noupdate /temp_controller_tb/DUT_inst/ow_out
add wave -noupdate /temp_controller_tb/DUT_inst/ow_in
add wave -noupdate /temp_controller_tb/DUT_inst/temp_f
add wave -noupdate -radix decimal /temp_controller_tb/DUT_inst/pid_p/pid_in
add wave -noupdate -format Analog-Step -height 88 -min -6147.0 -radix decimal /temp_controller_tb/DUT_inst/pid_p/pid_out
add wave -noupdate -format Analog-Step -height 88 -max 1408.0 -min 1023.0 -radix unsigned /temp_controller_tb/DUT_inst/mod_lvl
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {419449950446 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 381
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
WaveRestoreZoom {25 ms} {525 ms}
