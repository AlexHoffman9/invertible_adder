// Alex Hoffman, McGill University
// Top level module for invertible AND gate
// clamp inputs control which bits are fixed inputs (_clamp=2'b1x), outputs (_clamp=2'b0x)
`include "pbit/pbit.v"
module invertible_and(clk, reset, a_clamp, b_clamp, y_clamp, p_bits);
input clk, reset;
input [1:0] a_clamp, b_clamp, y_clamp;
wire [3:0] I_0;
output [2:0] p_bits;
wire [2:0] update_control; // update sequencer output

assign I_0 = 4'd1;
localparam N_NEIGHBORS = 2, WEIGHT_PRECISION = 6, SEED = 32'h48390184, H = 6'd0, W = {-6'd1, -6'd1, 6'd1}; 
// three pbits
// weights multiplied by 4 because of 2 fractional bits
// weights = weights in row ignoring the zero weight applied to onesself. {} list starts from right side of J matrix (looks mirrored)
// p_in bits are the other pbit outputs
pbit #(32'h45bc3a97, N_NEIGHBORS, WEIGHT_PRECISION, 6'd4, {6'd8, -6'd4}) 
a(.clk, .reset, .p_in(p_bits[2:1]), .I_0, .update_control(update_control[0]), .clamp_control(a_clamp), .p_out(p_bits[0]));

pbit #(32'h876b1c36, N_NEIGHBORS, WEIGHT_PRECISION, 6'd4, {6'd8, -6'd4})
b(.clk, .reset, .p_in({p_bits[2],p_bits[0]}), .I_0, .update_control(update_control[1]), .clamp_control(b_clamp), .p_out(p_bits[1]));

pbit #(32'h48390184, N_NEIGHBORS, WEIGHT_PRECISION, -6'd8, {6'd8, 6'd8}) 
y(.clk, .reset, .p_in(p_bits[1:0]), .I_0, .update_control(update_control[2]), .clamp_control(y_clamp), .p_out(p_bits[2]));

// update sequencer
update_sequencer #(3) updater(.clk, .reset, .update_out(update_control));
endmodule


`timescale 1ns/1ps
module invertible_and_tb();
reg clk, reset;
wire [2:0] p_bits;
reg [1:0] a_clamp, b_clamp, y_clamp;

invertible_and dut(.clk, .reset, .a_clamp, .b_clamp, .y_clamp, .p_bits);

parameter CLOCK_PERIOD = 20;
initial // Clock setUp
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

integer i; integer steps = 1000; integer sum = 0; integer sum_a=0; integer sum_b = 0;
initial 
begin
    // a=1, b=1, y=?
    reset <= 1; a_clamp <= 2'b11; b_clamp <= 2'b11; y_clamp <= 2'b00; #CLOCK_PERIOD;#CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[2] - 1;
    end
    $display("a,b = %b, average y = %f after %d cycles", {a_clamp[0],b_clamp[0]}, sum*1.0/steps, steps);
    
    // a=0, b=1, y=?
    sum=0;
    reset <= 1; a_clamp <= 2'b10; b_clamp <= 2'b11; y_clamp <= 2'b00; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[2] - 1;
    end
    $display("a,b = %b, average y = %f after %d cycles", {a_clamp[0],b_clamp[0]}, sum*1.0/steps, steps);
    
    // a=1, b=0, y=?
    sum=0;
    reset <= 1; a_clamp <= 2'b11; b_clamp <= 2'b10; y_clamp <= 2'b00; #CLOCK_PERIOD;#CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[2] - 1;
    end
    $display("a,b = %b, average y = %f after %d cycles", {a_clamp[0],b_clamp[0]}, sum*1.0/steps, steps);
 
    // a=0, b=0, y=?
    sum=0;
    reset <= 1; a_clamp <= 2'b10; b_clamp <= 2'b10; y_clamp <= 2'b00; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[2] - 1; 
    end
    $display("a,b = %b, average y = %f after %d cycles", {a_clamp[0],b_clamp[0]}, sum*1.0/steps, steps);
 
    // a=1, b=?, y=1
    sum=0;
    reset <= 1; a_clamp <= 2'b11; b_clamp <= 2'b01; y_clamp <= 2'b11; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[1] - 1;
    end
    $display("a=%b, y=%b, average b = %f after %d cycles", a_clamp[0], y_clamp[0], sum*1.0/steps, steps);

    // a=1, b=?, y=0
    sum=0;
    reset <= 1; a_clamp <= 2'b11; b_clamp <= 2'b01; y_clamp <= 2'b10; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[1] - 1;
    end
    $display("a=%b, y=%b, average b = %f after %d cycles", a_clamp[0], y_clamp[0], sum*1.0/steps, steps);

    // a=0, b=?, y=1
    sum=0;
    reset <= 1; a_clamp <= 2'b10; b_clamp <= 2'b01; y_clamp <= 2'b11; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[1] - 1;
    end
    $display("a=%b, y=%b, average b = %f after %d cycles", a_clamp[0], y_clamp[0], sum*1.0/steps, steps);

    // a=0, b=?, y=0
    sum=0;
    reset <= 1; a_clamp <= 2'b10; b_clamp <= 2'b01; y_clamp <= 2'b10; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[1] - 1;
    end
    $display("a=%b, y=%b, average b = %f after %d cycles", a_clamp[0], y_clamp[0], sum*1.0/steps, steps);



    // a=?, b=1, y=1
    sum=0;
    reset <= 1; a_clamp <= 2'b01; b_clamp <= 2'b11; y_clamp <= 2'b11; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[0] - 1;
    end
    $display("b=%b, y=%b, average a = %f after %d cycles", b_clamp[0], y_clamp[0], sum*1.0/steps, steps);

    // a=?, b=1, y=0
    sum=0;
    reset <= 1; a_clamp <= 2'b01; b_clamp <= 2'b11; y_clamp <= 2'b10; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[0] - 1;
    end
    $display("b=%b, y=%b, average a = %f after %d cycles", b_clamp[0], y_clamp[0], sum*1.0/steps, steps);

    // a=?, b=0, y=1
    sum=0;
    reset <= 1; a_clamp <= 2'b00; b_clamp <= 2'b10; y_clamp <= 2'b11; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[0] - 1;
    end
    $display("b=%b, y=%b, average a = %f after %d cycles", b_clamp[0], y_clamp[0], sum*1.0/steps, steps);

    // a=?, b=0, y=0
    sum=0;
    reset <= 1; a_clamp <= 2'b00; b_clamp <= 2'b10; y_clamp <= 2'b10; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum = sum + 2*p_bits[0] - 1;
    end
    $display("b=%b, y=%b, average a = %f after %d cycles", b_clamp[0], y_clamp[0], sum*1.0/steps, steps);



    // a=?, b=?, y=0
    sum_a = 0; sum_b = 0;
    reset <= 1; a_clamp <= 2'b00; b_clamp <= 2'b00; y_clamp <= 2'b10; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum_a = sum_a + 2*p_bits[0] - 1;
        sum_b = sum_b + 2*p_bits[1] - 1;
    end
    $display("y=%b, average a = %f,b = %f, after %d cycles", y_clamp[0], sum_a*1.0/steps, sum_b*1.0/steps, steps);

    // a=?, b=?, y=1
    sum_a = 0; sum_b = 0;
    reset <= 1; a_clamp <= 2'b00; b_clamp <= 2'b00; y_clamp <= 2'b11; #CLOCK_PERIOD; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for(i = 0; i < steps; i = i+1) begin
        #CLOCK_PERIOD;
        sum_a = sum_a + 2*p_bits[0] - 1;
        sum_b = sum_b + 2*p_bits[1] - 1;
    end
    $display("y=%b, average a = %f,b = %f, after %d cycles", y_clamp[0], sum_a*1.0/steps, sum_b*1.0/steps, steps);
    $stop;
end
endmodule