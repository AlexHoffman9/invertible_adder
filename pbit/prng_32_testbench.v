`timescale 1ns / 1ps
module prng_32_testbench();
wire[31:0] out;
reg clk, reset;
reg[31:0] seed; 

prng_32 dut(clk, reset, seed, out);

parameter CLOCK_PERIOD = 20;
	initial // Clock setUp
	begin
		clk = 0; 
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

integer i;
initial 
begin
    clk <= 0; reset <= 1; seed <= 32'h6a53d9f4;
    #CLOCK_PERIOD; reset <= 0;
    
    for (i = 0; i <= 64; i = i + 1) begin 
        #CLOCK_PERIOD;
    end
    #CLOCK_PERIOD reset <= 1;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;
    $stop;
end
endmodule