// Alex Hoffman, McGill University
// out returns I_i(t), the scaled sum of weighted p_bits: out = I_0*(h + sum(w*p_in))
module mac(p_in, I_0, out);

parameter N_NEIGHBORS=4, WEIGHT_PRECISION=6, H=6'd2, W={6'd1, 6'd1, 6'd1, 6'd3};
localparam OUT_PRECISION = 6;
localparam signed max_threshold = $signed({1'b0,{OUT_PRECISION-1{1'b1}}}); // sets thresholds based on weight precision parameters
localparam signed min_threshold = $signed({1'b1,{OUT_PRECISION-1{1'b0}}}); // assumes weight threshold == output threshold

input [N_NEIGHBORS-1:0] p_in;   // input p bits
input [3:0] I_0; // unsigned scaling. fixed point [2][2]
output reg signed [OUT_PRECISION-1:0] out;
reg signed [WEIGHT_PRECISION-1:0] weighted_p[N_NEIGHBORS-1:0];
reg signed [WEIGHT_PRECISION+3:0] weighted_sum;  // max 16 connections
reg signed [WEIGHT_PRECISION+7:0] scaled_sum;  // max 16 connections; scqled by 4 bit I_0, then shifted two back right
reg signed [WEIGHT_PRECISION+7:0] scaled_sum_preshift; // for debugging
// multiply p bits with weights in combinational logic
integer i;
always @(*)
begin
    // multiply weights by pbits. pbit of zero corresponds to -1. should synthesize to mux
    for (i = 0; i < N_NEIGHBORS; i = i + 1) begin // start from weight 1 because weight 0 is the constant offset
        if (p_in[i] == 1'b1) begin
            weighted_p[i] = W[WEIGHT_PRECISION*i +: WEIGHT_PRECISION]; // verilog requires constant vector size so have to use "variable part select" notation
        end else begin
            weighted_p[i] = ~W[WEIGHT_PRECISION*i +: WEIGHT_PRECISION] + 1; // p_bit == 0 represents -1, so negate the weight
        end
    end

    // sum weighted bits
    // This implementation is inefficient in area because it adds the values sequentially with independent adders. Could reuse adder 
    // but would need synchronous design
    // TODO: can make this O(log(n)) delay by branching the summations sum = (a+b) + (c+d) 
    weighted_sum = $signed(H);
    for (i = 0; i < N_NEIGHBORS; i = i + 1) begin
        // doing manual sign extension
        weighted_sum = weighted_sum + $signed(weighted_p[i]); //{{4{weighted_p[i][WEIGHT_PRECISION-1]}}, weighted_p[i]};   // blocking addition because we need cumulative sum
    end

    // scale with I_0
    // scaled_sum_preshift = $signed(weighted_sum * $signed(I_0));
    scaled_sum_preshift = weighted_sum * $signed({1'b0,I_0});
    scaled_sum = scaled_sum_preshift>>>2; // multiply by scaling. scaled sum is 

    // Thresholding of scaled sum
    if (scaled_sum > max_threshold) begin
        out = max_threshold; 
    end else if( scaled_sum < min_threshold) begin
        out = min_threshold;
    end else begin
        out = scaled_sum[OUT_PRECISION-1:0];
    end
end
endmodule


`timescale 1ns/1ps
module mac_tb();
localparam N_NEIGHBORS=4, WEIGHT_PRECISION=3, H=3'd3, W={3'd3,3'd3,3'd3,3'd3}; //W={-3'd4,-3'd4,-3'd4,-3'd4};
reg[N_NEIGHBORS-1:0] p_in;   // input p bits
reg[3:0] I_0;
wire[5:0] out;
 
mac#(N_NEIGHBORS, WEIGHT_PRECISION, H, W) dut(p_in, I_0, out);

integer i;
initial begin
    p_in <= 4'b1111; I_0 <= 4'd15; #10;
    // for (i=0; i<=3; i = i + 1)  begin
    //     w[i] <= 6'd1;
    // end
    #10; I_0 <= 4'd1;
    #10; I_0 <= 4'd3;
    #10; I_0 <= 4'd4;
    #10; I_0 <= 4'd6;
    #10; I_0 <= 4'd7;
    #10; I_0 <= 4'd8;
    #10; I_0 <= 4'd9;
    #10; I_0 <= 4'd11;
    #10; I_0 <= 4'd15;
    #10; p_in <= 4'b0000;
    #10; I_0 <= 4'd1;
    #10; I_0 <= 4'd3;
    #10; I_0 <= 4'd4;
    #10; I_0 <= 4'd6;
    #10; I_0 <= 4'd7;
    #10; I_0 <= 4'd8;
    #10; p_in <= 4'b1111;
    #10; p_in <= 4'b1011;
    #10; p_in <= 4'b1000;
end 
endmodule