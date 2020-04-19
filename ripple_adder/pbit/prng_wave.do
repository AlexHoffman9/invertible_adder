onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /prng_8_tb/clk
add wave -noupdate /prng_8_tb/reset
add wave -noupdate /prng_8_tb/seed
add wave -noupdate /prng_8_tb/i
add wave -noupdate /prng_8_tb/out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82 ps} 0}
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
WaveRestoreZoom {4976800 ps} {5232800 ps}
