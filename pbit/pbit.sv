// Alex Hoffman, McGill University
//  weights shouldn't be an input port. They are static during operation so they should be initialized at compilation internal to module
// why is this an sv? system verilog supports arrays. verilog doesn't....i'll switch this file to sv togive it param array of weights

// outputs a stochastic "p-bit," biased random number depending on the outputs of its neighbors
module pbit(clk, reset, p_in, update_control, p_out);
parameter seed = 32'h98390184,      // seed for prng. Default is random
n_neighbors = 4,
weight_precision = 6, 
w = {6'd1, 6'd1, 6'd1, 6'd1}; // s[3][2] -8 to 7.75 range for tanh input

input clk, reset, update_control;
input[n_neighbors-1:0] p_in;   // input p bits
// input[n_neighbors][weight_precision-1:0] w;      // one weight for each neighbor plus offset weight w_0=h
output reg p_out;                  // output bit

wire[5:0] I_i;
wire[31:0] activation;
reg[31:0] sum;
// local vars to connect modules
wire[31:0] prng_out;

// prng
prng_32 prng(clk, reset, seed, prng_out);

// MAC. inputs: w, p_in. outputs: sum
// test p-bit with a 0 input for now
assign I_i = 6'd4;

// tanh. inputs: sum, outputs: activation
tanh tan(I_i, activation);

// change this to state machine, only updates p_out when activated
always@(*) begin
    sum = prng_out+activation; //don't think addition is really necessary here. Less delay if I do straight comparator
    p_out = prng_out[31]&activation[31] || ((prng_out[31]^activation[31])&sum[31]);  // if sum is negative
    p_out = ~p_out;
end
endmodule


`timescale 1ns/1ps
module pbit_testbench();
// parameter n_neighbors = 4, weight_precision = 6, ;
localparam n_neighbors = 4, weight_precision = 6, seed = 32'h48390184, w = {6'd1, 6'd1, 6'd1, 6'd1}; 
reg clk, reset;
wire[n_neighbors-1:0] p_in;   // input p bits
// wire[n_neighbors][weight_precision-1:0] w;      // one weight for each neighbor plus offset weight w_0=h
//input[31:0] seed;           // seed for prng. This should be changed to constant generated at compile time
wire p_out;                   // output bit
reg update_control;

// pbit#(32'h3b976c43,n_neighbors,weight_precision) dut(clk, reset, p_in, update_control, p_out);
pbit #(seed, n_neighbors, weight_precision, w) dut(clk, reset, p_in, update_control, p_out);

parameter CLOCK_PERIOD = 20;
	initial // Clock setUp
	begin
		clk = 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

integer i; integer sum = 0; integer steps = 2000;
initial 
begin
    clk <= 0; reset <= 1;
    #CLOCK_PERIOD; reset <= 0;
    
    for (i = 0; i <= steps; i = i + 1) begin 
        #CLOCK_PERIOD;
        sum = sum + 1;
        if (p_out == 1'b0) begin
            sum = sum-2;
        end
    end
    // #CLOCK_PERIOD reset <= 1;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;
    $display("average value = %f after %d bits", sum*1.0/steps, steps);
    $display("expected average value for tanh input %d is %f", 1, 0.76);
    $stop;
end
endmodule