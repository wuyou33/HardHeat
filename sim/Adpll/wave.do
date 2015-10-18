onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adpll_tb/DUT_inst/reset
add wave -noupdate /adpll_tb/DUT_inst/clk
add wave -noupdate /adpll_tb/DUT_inst/up
add wave -noupdate /adpll_tb/DUT_inst/down
add wave -noupdate -radix decimal /adpll_tb/DUT_inst/phase_time
add wave -noupdate /adpll_tb/DUT_inst/ref_in
add wave -noupdate /adpll_tb/DUT_inst/sig_out
add wave -noupdate -format Analog-Step -height 88 -max 2547479.9999999995 -min 1048580.0 -radix unsigned /adpll_tb/DUT_inst/tuning_word
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {44255555113 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
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
WaveRestoreZoom {49814453125 ps} {50009765625 ps}
