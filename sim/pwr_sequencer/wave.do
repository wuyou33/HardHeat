onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pwr_sequencer_tb/DUT_inst/reset
add wave -noupdate /pwr_sequencer_tb/DUT_inst/clk
add wave -noupdate /pwr_sequencer_tb/DUT_inst/start_in
add wave -noupdate -expand /pwr_sequencer_tb/DUT_inst/en_out
add wave -noupdate -expand /pwr_sequencer_tb/DUT_inst/fail_in
add wave -noupdate -radix binary -childformat {{/pwr_sequencer_tb/DUT_inst/status_out(2) -radix binary} {/pwr_sequencer_tb/DUT_inst/status_out(1) -radix binary} {/pwr_sequencer_tb/DUT_inst/status_out(0) -radix binary}} -expand -subitemconfig {/pwr_sequencer_tb/DUT_inst/status_out(2) {-height 20 -radix binary} /pwr_sequencer_tb/DUT_inst/status_out(1) {-height 20 -radix binary} /pwr_sequencer_tb/DUT_inst/status_out(0) {-height 20 -radix binary}} /pwr_sequencer_tb/DUT_inst/status_out
add wave -noupdate /pwr_sequencer_tb/DUT_inst/main_pwr_en_out
add wave -noupdate /pwr_sequencer_tb/DUT_inst/main_pwr_fail_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {882643546 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 390
configure wave -valuecolwidth 144
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
WaveRestoreZoom {1107094311 ps} {1851182375 ps}
