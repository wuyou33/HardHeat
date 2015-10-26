onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /resonant_pfd_tb/DUT_inst/reset
add wave -noupdate /resonant_pfd_tb/DUT_inst/clk
add wave -noupdate /resonant_pfd_tb/DUT_inst/ref_in
add wave -noupdate /resonant_pfd_tb/DUT_inst/sig_in
add wave -noupdate /resonant_pfd_tb/DUT_inst/ff
add wave -noupdate /resonant_pfd_tb/DUT_inst/up_out
add wave -noupdate /resonant_pfd_tb/DUT_inst/down_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {690005000 ps} 0}
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
configure wave -timelineunits ms
update
WaveRestoreZoom {9757047183 ps} {10012786991 ps}
