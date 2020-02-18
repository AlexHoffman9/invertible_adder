module update_sequencer(clk, reset, update_out);
parameter N_PBITS = 5;

input clk, reset;
output reg [N_PBITS-1:0] update_out;  // update control for each pbit


always @(posedge clk) begin
    if (reset) begin
        update_out <= {{N_PBITS-1{1'b0}}, 1'b1};            // restart sequence, update first pbit
    end else begin
        update_out[0] <= update_out[N_PBITS-1];             // wrap update bit around to start of sequence
        update_out[N_PBITS-1:1] <= update_out[N_PBITS-2:0]; // shift update bit along sequence
    end
end
endmodule

`timescale 1ns/1ps
module update_sequencer_tb();
localparam N_PBITS = 5;

reg clk, reset;
wire [N_PBITS-1:0] update_out;

update_sequencer #(N_PBITS) dut(clk, reset, update_out);

parameter CLOCK_PERIOD = 20;
initial // Clock setUp
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

integer i;
initial begin
    reset <= 1; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for (i=0; i < 12; i = i+1) begin
        #CLOCK_PERIOD;
    end
    $stop;
end
endmodule

