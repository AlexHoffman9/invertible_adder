// piecewise linear approximation of tanh
module fast_tanh(in, out);
parameter OUT_BITS=32;
input signed[5:0] in;  // 6 bits 2's complement fixed point. s[3][2] format
output reg signed[OUT_BITS-1:0] out; // 32 bit 2's comp output -1 to (almost) 1 range

reg signed [1:0] shift;
reg signed [OUT_BITS-1:0] shifted_in_masked, offset, signed_offset;
reg signed [OUT_BITS+2:0] shifted_in;
reg unsaturated;
wire sign;
// out = (in >>> shift)&unsaturated + sign*offset)
    // decoder: in -> index [0,0.5)=0, [0.5,1)=1, [1,2)=2, [2+]=3
    // shift = shift_LUT[index]. 0,1,2,
    // offset = offset_LUT[index]. 0,0.25,0.5,1
    //  

// in = s[2].[2] in two's comp
    // in==0[00][0][x]: shift=0, offset=0
    // in==0[00][1][x]: shift=1, offset=0.25
    // in==0[01][x][x]: shift=2, offset=0.5
    // else:            shift=x, offset=1 unsaturated=6'b000000
assign sign = in[5];
always@(*) begin
    casez (in)
        6'b00000?, 6'b111111: begin
            shift = 0;
            offset = {OUT_BITS{1'b0}};
            unsaturated = 1'b1;
        end
        6'b00001?, 6'b111101, 6'b111110: begin
            shift = 1;
            offset = {3'b001,{(OUT_BITS-3){1'b0}}};
            unsaturated = 1'b1;
        end
        6'b0001??, 6'b111001, 6'b11101?, 6'b111100: begin
            shift = 2;
            offset = {2'b01,{(OUT_BITS-2){1'b0}}};
            unsaturated = 1'b1;
        end
        default: begin // saturation
            shift = 6'bxxxxxx;
            offset = {1'b0,{(OUT_BITS-1){1'b1}}};
            unsaturated = 1'b0;
        end
    endcase
    shifted_in = $signed({in,{(OUT_BITS-3){1'b0}}}) >>> shift; // adds shift right 3 to account for 1's,2's,4's place. Shift back by "shift", then add the lower bits corresponding to s.[31] radix
    shifted_in_masked = shifted_in & {(OUT_BITS){unsaturated}};
    signed_offset = (offset^{OUT_BITS{sign}}) + sign; // XOR with 1 flips bits, xor with 0 leaves bits the same. only inverts if sign=1
    out = shifted_in_masked + signed_offset;
end
endmodule


`timescale 1ns/1ps
module fast_tanh_tb();
localparam BITS=8;
reg signed[5:0] in;  // 6 bits 2's complement fixed point. s[3][2] format
wire signed[BITS-1:0] out; // 32 bit 2's comp output -1 to (almost) 1 range

fast_tanh#(BITS) dut(in, out);

integer i=0;
integer test_data;
initial begin
    test_data = $fopen("../test_data/fast_tanh.csv", "w"); // open output file
    if (test_data) begin
        $display("file opened successfully");
    end else begin
        $stop;
    end
    $fdisplay(test_data, "in,out");

    for (i=-32; i <= 31; i=i+1) begin
        in <= i; #10;
        $fdisplay(test_data, "%d,%d", in, out);
    end

$fclose(test_data);
end

endmodule