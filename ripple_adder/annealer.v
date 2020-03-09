// temperature controller for simulated annealing
module annealer(clk, reset, log_tau, I_min, I_max, I_0);
parameter I_BITS = 16;
input clk, reset;
input[3:0] I_min, I_max;
input[3:0] log_tau; // input log tau, so actual time constant is 2^log_tau
output[3:0] I_0;

wire[3:0] delta_temp;  // difference between min and max temp
wire[I_BITS-1:0] tau;        // time steps per time constant.  can make tau and t >= I_BITS-4 in width because tau width >= log_tau+1 and log_tau+1 <= I_BITS-4
wire[I_BITS-1:0] initial_step;
wire[3:0] initial_step_shift;
reg[I_BITS-1:0] I;           // temperature being incremented
reg[I_BITS-1:0] step;        // amount we increment temperature per cycle
reg[I_BITS-1:0] t;           // time t since reset

assign I_0 = I[I_BITS-1:I_BITS-4];
assign delta_temp = I_max-I_min;
assign tau = 1 << log_tau;
assign initial_step_shift = I_BITS-5-log_tau; // I_BITS must be >= (5+log_tau). I_BITS-4 >= log_tau+1
assign initial_step = delta_temp << initial_step_shift;

always@(posedge clk) begin
    if (reset) begin
        I <= {I_min, {(I_BITS-4){1'b0}}};
        step <= initial_step;
        t <= 0;
    end else begin
        if (I_0 != I_max) begin  // increment I if it hasn't already saturated
            I <= I + step;
        end
        if (t == tau) begin // if we have reached tau, halve slope.
            t <= 0;
            if (step != 1) begin  // don't let step size go to zero
                step <= step >> 1;
            end
        end else begin
            t <= t + 1;
        end
    end
end
endmodule



`timescale 1ns/1ps
module annealer_tb();
reg clk, reset;
reg[3:0] I_min, I_max;
reg[3:0] log_tau; // input log tau, so actual time constant is 2^log_tau
wire[3:0] I_0;

annealer dut(.clk, .reset, .log_tau, .I_min, .I_max, .I_0);

parameter CLOCK_PERIOD = 2;
initial // Clock setUp
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

integer i; integer iters = 5000;
initial begin
    reset <= 1; log_tau<=10; I_min<=4'b0100; I_max<=4'b1100; #CLOCK_PERIOD;
    reset <=0; #CLOCK_PERIOD;

    for (i = 0; i < iters; i = i+1) begin
        #CLOCK_PERIOD;
    end
    $stop;
end
endmodule