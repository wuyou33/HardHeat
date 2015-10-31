onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rpm_counter_tb/DUT_inst/reset
add wave -noupdate /rpm_counter_tb/DUT_inst/clk
add wave -noupdate /rpm_counter_tb/DUT_inst/rpm_in
add wave -noupdate -radix unsigned /rpm_counter_tb/DUT_inst/rpm_out
add wave -noupdate /rpm_counter_tb/DUT_inst/rpm_out_f
add wave -noupdate /rpm_counter_tb/DUT_inst/fault_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17673216411 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 360
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
WaveRestoreZoom {0 ps} {54131949568 ps}
