onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /inv_ripple_adder_tb/reset
add wave -noupdate /inv_ripple_adder_tb/clk
add wave -noupdate /inv_ripple_adder_tb/mode
add wave -noupdate /inv_ripple_adder_tb/a
add wave -noupdate /inv_ripple_adder_tb/b
add wave -noupdate /inv_ripple_adder_tb/sum
add wave -noupdate /inv_ripple_adder_tb/I_0
add wave -noupdate /inv_ripple_adder_tb/a_out
add wave -noupdate /inv_ripple_adder_tb/b_out
add wave -noupdate /inv_ripple_adder_tb/sum_out
add wave -noupdate /inv_ripple_adder_tb/overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {199984046 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 324
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {23999979 ps} {24012633 ps}
