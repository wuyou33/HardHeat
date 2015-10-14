onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /filter_tb/DUT_inst/reset
add wave -noupdate /filter_tb/DUT_inst/clk
add wave -noupdate -radix decimal /filter_tb/DUT_inst/filt_in
add wave -noupdate -format Analog-Step -height 74 -max 2097151.0 -min 1048896.0 -radix unsigned /filter_tb/DUT_inst/filt_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 195
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {10 ms}
