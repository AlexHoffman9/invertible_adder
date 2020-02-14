`timescale 1ns/1ps
// unsigned 32 bit comparator
module comparator_32_testbench();
reg[31:0] a,b;
wire a_ge_b;

parameter CLOCK_PERIOD = 20;
comparator_32 dut(a, b, a_ge_b);

initial 
begin
    a <= 32'd1; b <= 32'd0;
    #CLOCK_PERIOD; b <= 32'd1;
    #CLOCK_PERIOD; b <= 32'd2;
    #CLOCK_PERIOD;
    $stop;
end
endmodule