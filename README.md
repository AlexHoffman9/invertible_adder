# invertible_adder
Stochastic computing invertible adder using verilog\
Uses stochastic bits (pbits) in a boltzmann machine architecture to perform addition and subtraction with the same hardware. 
## Modes of Operation
Forward: addition

Reverse: subtraction

Inverse: Floating operands for a fixed sum
## Flexible Design
Master branch is optimized for a 4 bit adder, but pre_optimization branch offers wider margins for other logic designs such as a multiplier
## Fast TANH Activation Function
TANH activation implemented in hardware using small lookup table and add,shift operations
## Annealing
Exponential temperature decay in hardware allows for adder to reliably converge to an accurate result
## Random bit generation
8 bit LFSR with unique seeds for each pbit for efficient and adequate stochasticity for a 4 bit adder
## ModelSim + Python Test Suite
Simulation data from Modelsim is written to .csv files and plotted using a python script to compare convergence performance
