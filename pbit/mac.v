// Alex Hoffman, McGill University
// out returns I_i(t), the scaled sum of weighted p_bits: out = I_0*(h + sum(w*p_in))
module mac(p_in, I_0, out);
parameter n_neighbors=4, weight_precision=6, w={6'd1, 6'd1, 6'd1, 6'd1};
input[n_neighbors-1:0] p_in;   // input p bits
// input[weight_precision-1:0] w[n_neighbors:0];  
input[3:0] I_0;
output[5:0] out;
reg[weight_precision-1:0] weighted_p[n_neighbors:0]; // =+w if p=1, =-w if p=-1. So mult by result = 2pw-w
reg[weight_precision+3:0] weighted_sum;  // max 16 connections

// multiply p bits with weights
integer i; integer j;
always @(*)
begin
    weighted_p[0] <= w[0]; // pass through w0 = h unmultiplied
    for (i = 1; i <= n_neighbors; i = i + 1) begin // for weight in weight register
        for (i = 1; i <= n_neighbors; i = i + 1) begin // for bit in weight
            weighted_p[i][j] <= w[i][j] & p_in[i]; // and bit of weight with input p bit. non blocking assignment <= so the and gates are in parallel
        end
    end

    // sum weighted bits
    // TODO: This implementation is inefficient in area because it adds the values sequentially with independent adders. Could reuse adder 
    // but would need synchronous design. Or 
    for (i = 0; i <= n_neighbors; i = i + 1) begin
        // i think sign extension is automatic... will test
        weighted_sum = weighted_sum + weighted_p[i];            // blocking addition because we need cumulative sum
    end

    // threshold output
    // if weighted sum > 7.75 or sum < -8
    
end

assign out = weighted_sum[5:0];
endmodule

`timescale 1ns/1ps
module mac_tb();
parameter n_neighbors=4, weight_precision=6, sum_precision=10;
reg[n_neighbors-1:0] p_in;   // input p bits
reg[weight_precision-1:0] w[n_neighbors:0];
wire [weight_precision-1:0] w_in[n_neighbors:0] = w;
reg[3:0] I_0;
wire[5:0] out;

// verilog doesn't like 2d array 
mac#(n_neighbors, weight_precision, sum_precision) dut(p_in, w_in, I_0, out);

integer i;
initial begin
    p_in <= 4'b1101; I_0 <= 0; 
    for (i=0; i<=3; i = i + 1)  begin
        w[i] <= 6'd2;
    end

end
endmodule