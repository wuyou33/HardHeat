onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /one_wire_tb/DUT_inst/reset
add wave -noupdate /one_wire_tb/DUT_inst/clk
add wave -noupdate /one_wire_tb/DUT_inst/reset_ow
add wave -noupdate /one_wire_tb/reset_done
add wave -noupdate /one_wire_tb/send_done
add wave -noupdate /one_wire_tb/receive_done
add wave -noupdate /one_wire_tb/ow_out
add wave -noupdate /one_wire_tb/DUT_inst/ow_in
add wave -noupdate /one_wire_tb/DUT_inst/busy_out
add wave -noupdate -radix binary /one_wire_tb/DUT_inst/data_in
add wave -noupdate /one_wire_tb/DUT_inst/data_in_f
add wave -noupdate /one_wire_tb/DUT_inst/receive_data_f
add wave -noupdate -radix binary /one_wire_tb/DUT_inst/data_out
add wave -noupdate /one_wire_tb/DUT_inst/data_out_f
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {677769411 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 233
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
WaveRestoreZoom {574995866 ps} {2075000218 ps}
