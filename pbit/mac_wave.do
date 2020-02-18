onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mac_tb/p_in
add wave -noupdate /mac_tb/w
add wave -noupdate -radix decimal /mac_tb/h
add wave -noupdate -radix decimal /mac_tb/dut/weighted_p
add wave -noupdate -radix decimal /mac_tb/dut/weighted_sum
add wave -noupdate -radix decimal /mac_tb/I_0
add wave -noupdate -radix decimal /mac_tb/dut/scaled_sum
add wave -noupdate -radix decimal /mac_tb/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8000 ps} 0}
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
