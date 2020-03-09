onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /annealer_tb/clk
add wave -noupdate /annealer_tb/reset
add wave -noupdate /annealer_tb/I_min
add wave -noupdate /annealer_tb/I_max
add wave -noupdate /annealer_tb/log_tau
add wave -noupdate /annealer_tb/dut/tau
add wave -noupdate /annealer_tb/dut/I
add wave -noupdate /annealer_tb/dut/delta_temp
add wave -noupdate /annealer_tb/dut/t
add wave -noupdate /annealer_tb/dut/step
add wave -noupdate /annealer_tb/I_0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {190012 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
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
WaveRestoreZoom {188800 ps} {203992 ps}
