onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /fast_tanh_tb/in
add wave -noupdate /fast_tanh_tb/out
add wave -noupdate /fast_tanh_tb/dut/shift
add wave -noupdate /fast_tanh_tb/dut/offset
add wave -noupdate /fast_tanh_tb/dut/signed_offset
add wave -noupdate /fast_tanh_tb/dut/unsaturated
add wave -noupdate -radix binary /fast_tanh_tb/dut/shifted_in
add wave -noupdate -radix binary /fast_tanh_tb/dut/shifted_in_masked
add wave -noupdate /fast_tanh_tb/dut/sign
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {343498 ps} 0}
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
WaveRestoreZoom {319033 ps} {383033 ps}
