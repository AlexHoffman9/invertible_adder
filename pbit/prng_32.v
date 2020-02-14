// Alex Hoffman, McGill University

// 32 bit lsfr based psuedo random number generator, outputs 32 bits
module prng_32 (clk, reset, seed, out);
input clk, reset;
input[31:0] seed;
output [31:0] out;

// 32,22,2,1 taps
reg[31:0] lsfr;
wire feedback;

// taps at 32,22,2,1
assign feedback = lsfr[31] ^ lsfr[21] ^ lsfr[1] ^ lsfr[0];

assign out = lsfr;

always @ (posedge clk) begin
    if (reset) begin
        lsfr <= seed;
    end
    else begin
        lsfr[31:1] <= lsfr[30:0];
        lsfr[0] <= feedback;
    end
end
endmodule