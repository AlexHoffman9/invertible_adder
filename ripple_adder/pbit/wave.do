onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pbit_testbench/clk
add wave -noupdate /pbit_testbench/reset
add wave -noupdate /pbit_testbench/dut/update_control
add wave -noupdate /pbit_testbench/dut/clamp_control
add wave -noupdate /pbit_testbench/p_in
add wave -noupdate -radix decimal -childformat {{{/pbit_testbench/dut/I_i[5]} -radix decimal} {{/pbit_testbench/dut/I_i[4]} -radix decimal} {{/pbit_testbench/dut/I_i[3]} -radix decimal} {{/pbit_testbench/dut/I_i[2]} -radix decimal} {{/pbit_testbench/dut/I_i[1]} -radix decimal} {{/pbit_testbench/dut/I_i[0]} -radix decimal}} -subitemconfig {{/pbit_testbench/dut/I_i[5]} {-radix decimal} {/pbit_testbench/dut/I_i[4]} {-radix decimal} {/pbit_testbench/dut/I_i[3]} {-radix decimal} {/pbit_testbench/dut/I_i[2]} {-radix decimal} {/pbit_testbench/dut/I_i[1]} {-radix decimal} {/pbit_testbench/dut/I_i[0]} {-radix decimal}} /pbit_testbench/dut/I_i
add wave -noupdate /pbit_testbench/dut/activation
add wave -noupdate /pbit_testbench/dut/prng_out
add wave -noupdate /pbit_testbench/dut/sum
add wave -noupdate /pbit_testbench/p_out
add wave -noupdate /pbit_testbench/dut/tan/in
add wave -noupdate /pbit_testbench/dut/tan/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7495 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {64 ns}
