`timescale 1ns/1ps
module tanh_testbench();
reg[5:0] in;
wire[31:0] out;

tanh dut(in, out);

integer i;
initial  
begin
    in <= -6'd32; #10;
    for (i=0; i < 64; i = i+1) begin
        #10; in = in+1;
    end
end
endmodule