// Alex Hoffman, McGill University
// out returns I_i(t), the scaled sum of weighted p_bits: out = I_0*(h + sum(w*p_in))
module mac(p_in, I_0, out);

parameter n_neighbors=4, weight_precision=6, h=6'd2, w={6'd1, 6'd1, 6'd1, 6'd3};
localparam signed max_threshold = {1'b0,{weight_precision-1{1'b1}}}; // sets thresholds based on weight precision parameters
localparam signed min_threshold = {1'b1,{weight_precision-1{1'b0}}}; // assumes weight threshold == output threshold

input [n_neighbors-1:0] p_in;   // input p bits
input [3:0] I_0; // unsigned scaling
output reg signed [weight_precision-1:0] out;
reg signed [weight_precision-1:0] weighted_p[n_neighbors-1:0];
reg signed [weight_precision+3:0] weighted_sum;  // max 16 connections
reg signed [weight_precision+7:0] scaled_sum;  // max 16 connections; scqled by 4 bit I_0

// multiply p bits with weights in combinational logic
integer i;
always @(*)
begin
    // multiply weights by pbits. pbit of zero corresponds to -1. should synthesize to mux
    for (i = 0; i < n_neighbors; i = i + 1) begin // start from weight 1 because weight 0 is the constant offset
        if (p_in[i] == 1'b1) begin
            weighted_p[i] = w[weight_precision*i +: weight_precision]; // verilog requires constant vector size so have to use "variable part select" notation
        end else begin
            weighted_p[i] = ~w[weight_precision*i +: weight_precision] + 1; // p_bit == 0 represents -1, so negate the weight
        end
    end

    // sum weighted bits
    // This implementation is inefficient in area because it adds the values sequentially with independent adders. Could reuse adder 
    // but would need synchronous design
    // TODO: can make this O(log(n)) delay by branching the summations sum = (a+b) + (c+d) 
    weighted_sum = $signed(h);
    for (i = 0; i < n_neighbors; i = i + 1) begin
        // doing manual sign extension
        weighted_sum = weighted_sum + $signed(weighted_p[i]); //{{4{weighted_p[i][weight_precision-1]}}, weighted_p[i]};   // blocking addition because we need cumulative sum
    end

    // scale with I_0
    scaled_sum = $signed(weighted_sum * I_0);

    // this part is not parameterized but can be fixed in future
    if (scaled_sum > max_threshold) begin
        out = max_threshold; 
    end else if( scaled_sum < min_threshold) begin
        out = min_threshold;
    end else begin
        out = scaled_sum[5:0];
    end
end
endmodule


`timescale 1ns/1ps
module mac_tb();
localparam n_neighbors=4, weight_precision=5, h=-5'd1, w={-5'd2, -5'd2, -5'd2, -5'd2};
reg[n_neighbors-1:0] p_in;   // input p bits
// reg[weight_precision-1:0] w[n_neighbors:0];
// wire [weight_precision-1:0] w_in[n_neighbors:0] = w;
reg[3:0] I_0;
wire[4:0] out;

// verilog doesn't like 2d array 
mac#(n_neighbors, weight_precision, h, w) dut(p_in, I_0, out);

integer i;
initial begin
    p_in <= 4'b0000; I_0 <= 4'd2; #10;
    // for (i=0; i<=3; i = i + 1)  begin
    //     w[i] <= 6'd1;
    // end
    #10; p_in <= 4'b1010;
    #10; p_in <= 4'b1111;
    #10; p_in <= 4'b1011;
    #10; p_in <= 4'b1000;
    #10;
end 
endmodule