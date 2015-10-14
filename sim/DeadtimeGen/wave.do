onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /deadtime_gen_tb/DUT_inst/reset
add wave -noupdate /deadtime_gen_tb/DUT_inst/clk
add wave -noupdate -format Analog-Step -height 84 -max 4194300.0 -min 3994400.0 -radix unsigned /deadtime_gen_tb/tuning_word
add wave -noupdate /deadtime_gen_tb/DUT_inst/sig_in
add wave -noupdate /deadtime_gen_tb/DUT_inst/sig_out
add wave -noupdate /deadtime_gen_tb/DUT_inst/sig_n_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {943697763 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 257
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
WaveRestoreZoom {940625 ns} {1003125 ns}
