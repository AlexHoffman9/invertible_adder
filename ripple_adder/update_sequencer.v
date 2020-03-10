module update_sequencer(clk, reset, update_mode, update_out);
parameter N_PBITS = 5;

input clk, reset, update_mode;
output reg [N_PBITS-1:0] update_out;  // update control for each pbit
wire [N_PBITS-1:0] mode;
reg last_update_mode;


always @(posedge clk) begin
    if (reset | (last_update_mode ^ update_mode)) begin                              // if reset or mode change 
        update_out <= {{N_PBITS-1{1'b0}}, 1'b1} | {N_PBITS{update_mode}};            // restart sequence, update first pbit
        last_update_mode <= update_mode;
    end else begin
        update_out[0] <= update_out[N_PBITS-1] | update_mode;             // wrap update bit around to start of sequence
        update_out[N_PBITS-1:1] <= update_out[N_PBITS-2:0] | {N_PBITS-1{update_mode}}; // shift update bit along sequence
        last_update_mode <= update_mode;
    end
end


// always @(posedge clk) begin
//     if (reset) begin
//         update_out <= {{N_PBITS{1'b1}};            // restart sequence, update first pbit
//     end else begin
//         update_out <= {{N_PBITS{1'b1}};
//     end
// end
endmodule

`timescale 1ns/1ps
module update_sequencer_tb();
localparam N_PBITS = 5;

reg clk, reset, update_mode;
wire [N_PBITS-1:0] update_out;

update_sequencer #(N_PBITS) dut(clk, reset, update_mode, update_out);

parameter CLOCK_PERIOD = 20;
initial // Clock set Up
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

integer i;
initial begin
    reset <= 1; update_mode <=0; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for (i=0; i < 12; i = i+1) begin
        #CLOCK_PERIOD;
    end
    update_mode <=1;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;
    update_mode <=0;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;#CLOCK_PERIOD;
    $stop;
end
endmodule

