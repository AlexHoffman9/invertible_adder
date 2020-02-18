onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /invertible_and_tb/clk
add wave -noupdate /invertible_and_tb/reset
add wave -noupdate /invertible_and_tb/a_clamp
add wave -noupdate /invertible_and_tb/b_clamp
add wave -noupdate /invertible_and_tb/y_clamp
add wave -noupdate -expand /invertible_and_tb/p_bits
add wave -noupdate /invertible_and_tb/dut/b/W
add wave -noupdate /invertible_and_tb/dut/b/mac_pbit/p_in
add wave -noupdate -radix decimal /invertible_and_tb/dut/b/mac_pbit/weighted_p
add wave -noupdate -radix decimal /invertible_and_tb/dut/b/mac_pbit/weighted_sum
add wave -noupdate -radix decimal /invertible_and_tb/dut/b/mac_pbit/scaled_sum
add wave -noupdate -radix decimal /invertible_and_tb/dut/b/I_i
add wave -noupdate /invertible_and_tb/dut/b/activation
add wave -noupdate /invertible_and_tb/dut/b/prng_out
add wave -noupdate /invertible_and_tb/dut/b/sum
add wave -noupdate /invertible_and_tb/dut/b/update_control
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21033 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 327
configure wave -valuecolwidth 64
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
WaveRestoreZoom {19862757 ps} {20070382 ps}
