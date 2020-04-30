// Alex Hoffman, McGill University

// 8 bit lsfr based psuedo random number generator, outputs 9 bits
module prng_8(clk, reset, seed, out);
input clk, reset;
input[7:0] seed;
output [7:0] out;

// 8,6,5,4 taps (subtract by one for 0 based indexing
reg[7:0] lsfr;
wire feedback;

// taps at 32,22,2,1
assign feedback = lsfr[7] ^ lsfr[5] ^ lsfr[4] ^ lsfr[3];

assign out = lsfr;

always @ (posedge clk) begin
    if (reset) begin
        lsfr <= seed;
    end
    else begin
        lsfr[7:1] <= lsfr[6:0];
        lsfr[0] <= feedback;
    end
end
endmodule

`timescale 1ns/1ps
module prng_8_tb();
wire [7:0] out;
reg clk, reset;
reg [7:0] seed;

prng_8 dut(.clk, .reset, .seed, .out);

parameter CLOCK_PERIOD = 20;
initial // Clock setup
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

integer i;
initial 
begin
    clk <= 0; reset <= 1; seed <= 8'h6a;
    #CLOCK_PERIOD; reset <= 0;
    
    for (i = 0; i <= 255; i = i + 1) begin 
        #CLOCK_PERIOD;
    end
    #CLOCK_PERIOD reset <= 1;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;
    $stop;
end

endmodule