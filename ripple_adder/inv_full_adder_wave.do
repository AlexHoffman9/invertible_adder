onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /inv_full_adder_tb/clk
add wave -noupdate /inv_full_adder_tb/reset
add wave -noupdate -radix binary /inv_full_adder_tb/a_clamp
add wave -noupdate -radix binary /inv_full_adder_tb/s_clamp
add wave -noupdate -radix binary /inv_full_adder_tb/cin_clamp
add wave -noupdate -radix binary /inv_full_adder_tb/b_clamp
add wave -noupdate -radix binary /inv_full_adder_tb/cout_clamp
add wave -noupdate -radix binary /inv_full_adder_tb/p_bits
add wave -noupdate -radix decimal /inv_full_adder_tb/dut/b/mac_pbit/weighted_p
add wave -noupdate -radix binary /inv_full_adder_tb/dut/b/mac_pbit/p_in
add wave -noupdate -radix decimal /inv_full_adder_tb/dut/b/mac_pbit/W
add wave -noupdate -radix decimal /inv_full_adder_tb/dut/b/mac_pbit/weighted_sum
add wave -noupdate -radix unsigned /inv_full_adder_tb/dut/b/mac_pbit/scaled_sum
add wave -noupdate -radix unsigned /inv_full_adder_tb/dut/b/activation
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {355656974 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 316
configure wave -valuecolwidth 216
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
WaveRestoreZoom {1600239615 ps} {1600324231 ps}
