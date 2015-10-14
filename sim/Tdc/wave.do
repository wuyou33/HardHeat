onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tdc_tb/DUT_inst/reset
add wave -noupdate /tdc_tb/DUT_inst/clk
add wave -noupdate /tdc_tb/DUT_inst/up_in
add wave -noupdate /tdc_tb/DUT_inst/down_in
add wave -noupdate -radix decimal /tdc_tb/DUT_inst/time_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {925005000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 221
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
WaveRestoreZoom {0 ps} {764322732 ps}
