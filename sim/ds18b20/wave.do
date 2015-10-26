onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ds18b20_tb/DUT_inst/reset
add wave -noupdate /ds18b20_tb/DUT_inst/clk
add wave -noupdate /ds18b20_tb/DUT_inst/conv_in_f
add wave -noupdate -radix hexadecimal /ds18b20_tb/DUT_inst/data_in
add wave -noupdate /ds18b20_tb/DUT_inst/data_in_f
add wave -noupdate -radix hexadecimal /ds18b20_tb/DUT_inst/data_out
add wave -noupdate /ds18b20_tb/DUT_inst/data_out_f
add wave -noupdate /ds18b20_tb/DUT_inst/reset_ow_out
add wave -noupdate /ds18b20_tb/DUT_inst/busy_in
add wave -noupdate /ds18b20_tb/DUT_inst/receive_data_out_f
add wave -noupdate -radix hexadecimal /ds18b20_tb/DUT_inst/temp_out
add wave -noupdate /ds18b20_tb/DUT_inst/temp_out_f
add wave -noupdate /ds18b20_tb/DUT_inst/temp_error_out
add wave -noupdate /ds18b20_tb/ow_out
add wave -noupdate /ds18b20_tb/ow_in
add wave -noupdate /ds18b20_tb/DUT_inst/error_in
add wave -noupdate /ds18b20_tb/DUT_inst/error_id_in
add wave -noupdate /ds18b20_tb/DUT_inst/crc_in
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17496476824 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 384
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
WaveRestoreZoom {12082566940 ps} {20416707004 ps}
