# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
#vlog -sv "./inv_ripple_adder.sv" +incdir+C:\Modeltech_pe_edu_10.4a\uvm-1.2\Accellera-1800.2-2017-1.0\1800.2-2017-1.0\src +define+UVM_CMDLINE_NO_DPI +define+UVM_REGEX_NO_DPI +define+UVM_NO_DPI

#vlog -sv "./inv_ripple_adder.sv"
vlog "./inv_ripple_adder.v"
vlog "./inv_full_adder.v"
vlog "./update_sequencer.v"
vlog "./pbit/*.v"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work inv_ripple_adder_tb

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do inv_ripple_adder_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End