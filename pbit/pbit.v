// Alex Hoffman, McGill University
// outputs a stochastic "p-bit:" a biased random bit depending on the outputs of its neighbors
module pbit(clk, reset, p_in, I_0, update_control, clamp_control, p_out);
parameter seed = 32'h98390184,      // seed for prng
n_neighbors = 4,                    // number of pbit connections
weight_precision = 6,               // bit precision of weights, tanh input
h = 6'd1,                           // constant offset for this pbit
w = {6'd1, 6'd1, 6'd1, 6'd1};       // weights for this pbit in s[3][2] format -8 to 7.75 range for tanh input

input clk, reset, update_control;   // clk, reset, update_control==1 allows pbit to update its output, otherwise it holds
input[n_neighbors-1:0] p_in;        // input p bits
input [3:0] I_0;                    // unsigned scaling
input [1:0] clamp_control;          // msb = clamp enable, lsb = clamped value
output reg p_out;                   // output bit

// local vars to connect modules
wire[5:0] I_i;                      // output of MAC, input to activation function
wire[31:0] activation;              // output of activation function
wire[31:0] sum;                     // sum of prng and activation output. The output is drawn from the sign of this sum
wire[31:0] prng_out;                // pseudo random number generated by lfsr

// prng
prng_32 prng(clk, reset, seed, prng_out);

// MAC. Outputs weighted sum of input pbits, thresholded to 6 bits
mac #(n_neighbors, weight_precision, h, w) mac_pbit(p_in, I_0, I_i);

// tanh. inputs: I_i (MAC output), outputs: activation
tanh tan(I_i, activation);

// combinational logic for sum of random number and activation output
assign sum = prng_out+activation; 

// sequential logic for updating output bit
always@(posedge clk) begin
    if (clamp_control[1] == 1'b1) begin // if pbit output should be clamped to a value (this pbit acts as input to boltzmann machine)
        p_out <= clamp_control[0];
    end else begin 
        if (update_control || reset) begin // update pbit when told or on reset
            p_out <= ~(prng_out[31]&activation[31] || ((prng_out[31]^activation[31])&sum[31]));  // if sum is negative (operands are pos or operands are pos,neg and num to pos)
        end else begin // pbit should not be updated
            p_out <= p_out;
        end
    end
end
endmodule


`timescale 1ns/1ps
module pbit_testbench();
localparam n_neighbors = 4, weight_precision = 6, seed = 32'h48390184, h = 6'd0, w = {-6'd1, -6'd1, 6'd1, 6'd1}; 
reg clk, reset;
reg[n_neighbors-1:0] p_in;    // input p bits
reg [3:0] I_0;
wire p_out;                   // output bit
reg update_control;
reg [1:0] clamp_control; 

pbit #(seed, n_neighbors, weight_precision, h, w) dut(clk, reset, p_in, I_0, update_control, clamp_control, p_out);

parameter CLOCK_PERIOD = 20;
	initial // Clock setUp
	begin
		clk = 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

integer i; integer sum = 0; integer steps = 100;
initial 
begin
    clk <= 0; reset <= 1; I_0 <= 4'd1; p_in <= 4'b1111; clamp_control <= 2'b00; update_control <= 1'b1;
    #CLOCK_PERIOD; reset <= 0;#CLOCK_PERIOD; reset <= 1;#CLOCK_PERIOD; reset <= 0;
    #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; clamp_control <= 2'b10;
    #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; clamp_control <= 2'b11;
    #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; clamp_control <= 2'b01;
    #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; clamp_control <= 2'b01;
    // #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; #CLOCK_PERIOD; update_control <= 1'b0;
    for (i = 0; i < steps; i = i + 1) begin 
        #CLOCK_PERIOD;
        sum = sum + 2*p_out - 1;
    end
    $display("input weights = %b, average value = %f after %d bits", p_in, sum*1.0/steps, steps);
    // $display("expected average value for tanh input %d is %f", 1, 0.76);

    // p_in <= 4'b1110;sum=0;
    // for (i = 0; i < steps; i = i + 1) begin 
    //     #CLOCK_PERIOD;
    //     sum = sum + 2*p_out - 1;
    // end
    // $display("input weights = %b, average value = %f after %d bits", p_in, sum*1.0/steps, steps);
    // p_in <= 4'b1100; sum=0;
    // for (i = 0; i < steps; i = i + 1) begin 
    //     #CLOCK_PERIOD;
    //     sum = sum + 2*p_out - 1;
    // end
    // $display("input weights = %b, average value = %f after %d bits", p_in, sum*1.0/steps, steps);
    // p_in <= 4'b1000;sum=0;
    // for (i = 0; i < steps; i = i + 1) begin 
    //     #CLOCK_PERIOD;
    //     sum = sum + 2*p_out - 1;
    // end
    // $display("input weights = %b, average value = %f after %d bits", p_in, sum*1.0/steps, steps);
    //  p_in <= 4'b0000;sum=0;
    // for (i = 0; i < steps; i = i + 1) begin 
    //     #CLOCK_PERIOD;
    //     sum = sum + 2*p_out - 1;
    // end
    // $display("input weights = %b, average value = %f after %d bits", p_in, sum*1.0/steps, steps);
    $stop;
end
endmodule