// Alex Hoffman, McGill University
// Top level module for invertible full adder gate
// clamp inputs control which bits are fixed inputs (_clamp=2'b1x), outputs (_clamp=2'b0x)
// a, b, Cin, Cout, S
`include "pbit/pbit.v"
module inv_full_adder(clk, reset, I_0, update_mode, a_clamp, b_clamp, cin_clamp, s_clamp, cout_clamp, p_bits);
input clk, reset, update_mode;
input [1:0] a_clamp, b_clamp, cin_clamp, s_clamp, cout_clamp;
input [3:0] I_0;
output [4:0] p_bits;
wire [4:0] update_control; // update sequencer output

// temperature (constant for now)
// assign I_0 = 4'd1;

localparam N_NEIGHBORS = 4, WEIGHT_PRECISION = 6, SEED = 32'h48390184; 
// three pbits
// weights multiplied by 4 because of 2 fractional bits
// weights = weights in row ignoring the zero weight applied to onesself. {} list starts from right side of J matrix (looks mirrored)
// p_in bits are the other pbit outputs
// weight matrix values in order of bits a,b,cin,s,cout:
//  0−1−1+1+2
// −1 0−1+1+2
// −1−1 0+1+2
// +1+1+1 0−2
// +2+2+2−2 0

pbit #(32'h45bc3a97, N_NEIGHBORS, WEIGHT_PRECISION, 6'd0, {6'd8, 6'd4, -6'd4, -6'd4}) 
a(.clk, .reset, .p_in(p_bits[4:1]), .I_0, .update_control(update_control[0]), .clamp_control(a_clamp), .p_out(p_bits[0]));

pbit #(32'h876b1c36, N_NEIGHBORS, WEIGHT_PRECISION, 6'd0, {6'd8, 6'd4, -6'd4, -6'd4})
b(.clk, .reset, .p_in({p_bits[4:2],p_bits[0]}), .I_0, .update_control(update_control[1]), .clamp_control(b_clamp), .p_out(p_bits[1]));

pbit #(32'h48390184, N_NEIGHBORS, WEIGHT_PRECISION, 6'd0, {6'd8, 6'd4, -6'd4, -6'd4}) 
cin(.clk, .reset, .p_in({p_bits[4:3], p_bits[1:0]}), .I_0, .update_control(update_control[2]), .clamp_control(cin_clamp), .p_out(p_bits[2]));

pbit #(32'h86b827f4, N_NEIGHBORS, WEIGHT_PRECISION, 6'd0, {-6'd8, 6'd4, 6'd4, 6'd4}) 
s(.clk, .reset, .p_in({p_bits[4], p_bits[2:0]}), .I_0, .update_control(update_control[3]), .clamp_control(s_clamp), .p_out(p_bits[3]));

pbit #(32'ha34980df, N_NEIGHBORS, WEIGHT_PRECISION, 6'd0, {-6'd8, 6'd8, 6'd8, 6'd8}) 
cout(.clk, .reset, .p_in(p_bits[3:0]), .I_0, .update_control(update_control[4]), .clamp_control(cout_clamp), .p_out(p_bits[4]));

// update sequencer
update_sequencer #(5) updater(.clk, .reset, .update_mode, .update_out(update_control));
endmodule

`timescale 1ns/1ps
module inv_full_adder_tb();
reg clk, reset, update_mode;
reg [1:0] a_clamp, b_clamp, cin_clamp, s_clamp, cout_clamp;
reg [3:0] I_0;
wire [4:0] p_bits;

inv_full_adder dut(.clk, .reset, .I_0, .update_mode, .a_clamp, .b_clamp, .cin_clamp, .s_clamp, .cout_clamp, .p_bits);

parameter CLOCK_PERIOD = 20;
initial // Clock setUp
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

// reg[3:0] inputs = 4'b000;
integer i;integer j; integer steps = 10000; integer sum_a, sum_b, sum_cin, sum_cout, sum_s;
initial 
begin
    // // // fix inputs, cin, float s, cout
    // reset <= 1'b1; a_clamp = 2'b11; b_clamp <= 2'b11; cin_clamp <= 2'b11; s_clamp <= 2'b00; cout_clamp <= 2'b00; #CLOCK_PERIOD;
    // #CLOCK_PERIOD; reset <= 1'b0;
    // sum_s=0; sum_cout=0;
    // for (i=0; i<steps; i=i+1) begin
    //     #CLOCK_PERIOD;
    //     sum_s = sum_s + p_bits[3];
    //     sum_cout = sum_cout + p_bits[4];
    //     // $display("bit: %b",p_bits[4]);
    // end
    // $display("a,b,Cin = %b: average Sum = %f, Cout = %f after %d cycles", {a_clamp[0],b_clamp[0],cin_clamp[0]}, sum_s*1.0/steps, sum_cout*1.0/steps, steps);
    
    // inverse logic: fixed sum and cout (carry propagates from cout to cin)
    $display("Inverted logic results:");
    for (i = 0; i <= 3; i = i + 1) begin
        reset <= 1'b1; update_mode<=0; a_clamp = 2'b01; b_clamp <= 2'b01; cin_clamp <= 2'b01; s_clamp <= 2'b10; cout_clamp <= 2'b10; I_0<=4'd1; #CLOCK_PERIOD;
        s_clamp[0] <= i[1]; cout_clamp[0] <= i[0];
        #CLOCK_PERIOD; reset <= 1'b0;
        sum_a=0; sum_b=0; sum_cin = 0;
        for (j=0; j<steps; j=j+1) begin
            #CLOCK_PERIOD;
            sum_a = sum_a + p_bits[0];
            sum_b = sum_b + p_bits[1];
            sum_cin = sum_cin + p_bits[2];
        end
        $display("S, Cout = %b: average A = %f, B = %f, Cin = %f after %d cycles", {s_clamp[0],cout_clamp[0]}, sum_a*1.0/steps, sum_b*1.0/steps, sum_cin*1.0/steps, steps);
    end

    // Subtraction: fixed a,sum, cin (carry propagates from cout to cin)
    $display("");
    $display("Subtraction results:");
    for (i = 0; i <= 7; i = i + 1) begin
        reset <= 1'b1; a_clamp = 2'b11; b_clamp <= 2'b01; cin_clamp <= 2'b11; s_clamp <= 2'b10; cout_clamp <= 2'b00; I_0<=4'd1; #CLOCK_PERIOD;
        a_clamp[0] <= i[2]; s_clamp[0] <= i[1]; cin_clamp[0] <= i[0];
        #CLOCK_PERIOD; reset <= 1'b0;
        sum_a=0; sum_b=0; sum_cout = 0;
        for (j=0; j<steps; j=j+1) begin
            #CLOCK_PERIOD;
            sum_a = sum_a + p_bits[0];
            sum_b = sum_b + p_bits[1];
            sum_cout = sum_cout + p_bits[4];
        end
        $display("A, S, Cin = %b: B = %f, Cout = %f. after %d cycles", {a_clamp[0], s_clamp[0], cin_clamp[0]}, sum_b*1.0/steps, sum_cout*1.0/steps, steps);
        $display("Expected bit averages: %b.  Results: %b", {cin_clamp[0]^a_clamp[0]^s_clamp[0], a_clamp[0]&cin_clamp[0] | (a_clamp[0]^cin_clamp[0])&(~s_clamp[0])}, {sum_b*1.0/steps>0.5, sum_cout*1.0/steps>0.5});
    end 

    // Forward logic: fixed a,b,cin
    $display("");
    $display("Forward logic results: ");
    for (i = 0; i <= 7; i = i + 1) begin
        reset <= 1'b1; a_clamp = 2'b11; b_clamp <= 2'b11; cin_clamp <= 2'b11; s_clamp <= 2'b00; cout_clamp <= 2'b00; I_0<=4'd1; #CLOCK_PERIOD;
        a_clamp[0] <= i[2]; b_clamp[0] <= i[1]; cin_clamp[0] = i[0];
        #CLOCK_PERIOD; reset <= 1'b0;
        sum_s=0; sum_cout=0;
        for (j=0; j<steps; j=j+1) begin
            #CLOCK_PERIOD;
            sum_s = sum_s + p_bits[3];
            sum_cout = sum_cout + p_bits[4];
            // $display("bit: %b",p_bits[4]);
        end
        // $display("cout sum: %d", sum_cout);
        $display("a,b,Cin = %b: average Sum = %f, Cout = %f after %d cycles", {a_clamp[0],b_clamp[0],cin_clamp[0]}, sum_s*1.0/steps, sum_cout*1.0/steps, steps);
    end  
    $stop;
end

endmodule