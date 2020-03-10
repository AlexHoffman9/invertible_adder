onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /inv_full_adder_tb/clk
add wave -noupdate /inv_full_adder_tb/reset
add wave -noupdate /inv_full_adder_tb/update_mode
add wave -noupdate /inv_full_adder_tb/a_clamp
add wave -noupdate /inv_full_adder_tb/b_clamp
add wave -noupdate /inv_full_adder_tb/cin_clamp
add wave -noupdate /inv_full_adder_tb/s_clamp
add wave -noupdate /inv_full_adder_tb/cout_clamp
add wave -noupdate /inv_full_adder_tb/I_0
add wave -noupdate /inv_full_adder_tb/p_bits
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {199984046 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 324
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
configure wave -timelineunits ns
update
WaveRestoreZoom {4000751916 ps} {4000802531 ps}
