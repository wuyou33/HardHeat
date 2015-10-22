onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pid_tb/DUT_inst/reset
add wave -noupdate /pid_tb/DUT_inst/clk
add wave -noupdate /pid_tb/DUT_inst/upd_clk_in
add wave -noupdate -radix decimal /pid_tb/DUT_inst/pid_in
add wave -noupdate -format Analog-Step -height 88 -max 2097151.0 -min 2090752.0 -radix unsigned /pid_tb/DUT_inst/pid_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {1 ms}
