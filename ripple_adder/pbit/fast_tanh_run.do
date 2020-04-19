#vlog -sv "./inv_ripple_adder.sv"
vlog "./fast_tanh.v"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work fast_tanh_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do fast_tanh_wave.do
# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End