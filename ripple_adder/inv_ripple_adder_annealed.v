module inv_ripple_adder_annealed(clk, reset, mode, a, b, sum, a_out, b_out, sum_out, overflow, log_tau, I_min, I_max);
input reset, clk;
input [1:0] mode;
input [3:0] a, b, sum;
input [3:0] log_tau, I_min, I_max;
output [3:0] a_out, b_out, sum_out;
output overflow;
wire [3:0] I_0;

inv_ripple_adder dut(.clk, .reset, .mode, .I_0, .a, .b, .sum, .a_out, .b_out, .sum_out, .overflow);

annealer ann(.clk, .reset, .log_tau, .I_min, .I_max, .I_0);

endmodule



`timescale 1ns/1ps
module inv_ripple_adder_annealed_tb();
reg reset, clk;
reg [1:0] mode;
reg [3:0] a, b, sum;
reg [3:0] I_0;
wire [3:0] a_out, b_out, sum_out;
wire overflow;
reg[3:0] log_tau, I_min, I_max;

inv_ripple_adder_annealed dut(.clk, .reset, .mode, .a, .b, .sum, .a_out, .b_out, .sum_out, .overflow, .log_tau, .I_min, .I_max);

parameter CLOCK_PERIOD = 2;
initial // Clock setUp
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

// reg[3:0] inputs = 4'b000;
integer i; integer j; integer steps = 300; integer sum_a, sum_b, sum_cin, sum_cout, sum_s; integer net_sum[3:0];
integer test_data;
initial 
begin
    test_data = $fopen("test_data/t1.csv", "w"); // open output file
    if (test_data) begin
        $display("file opened successfully");
    end else begin
        $stop;
    end
    $fdisplay(test_data, "time,A,B,S,OVF,I0,Mode,Steps,LogTau");

    // mode=0 to test forward logic
    reset <=1; a <= 1; b <= 7; I_0 <= 1; mode <= 0; I_min<=4'b0010; I_max<=4'b1111; log_tau<=6; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for (i=0;i<4;i=i+1) begin
        net_sum[i] = 0;
    end
    $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow, I_0, mode, steps, log_tau);
    for (i=0;i<steps;i=i+1) begin
        #CLOCK_PERIOD;
        for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
            net_sum[j] <= net_sum[j] + sum_out[j];
        end
        $fdisplay(test_data, "%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow);
    end
    $display("Percentage of cycles where bit was equal to 1:");
    $display("A=%d,B=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, b, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    $display("Expected bit averages: %b.  Results: %b", a+b, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});

    
    // // mode=0 to test forward logic
    // reset <=1; a <= 7; b <= 9; I_0 <= 1; mode <= 0; #CLOCK_PERIOD;
    // reset <= 0; #CLOCK_PERIOD;
    // for (i=0;i<4;i=i+1) begin
    //     net_sum[i] = 0;
    // end
    // $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow, I_0, mode, steps);
    // for (i=0;i<steps;i=i+1) begin
    //     #CLOCK_PERIOD;
    //     for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
    //         net_sum[j] <= net_sum[j] + sum_out[j];
    //     end
    //     $fdisplay(test_data, "%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow);
    // end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,B=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, b, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b", a+b, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});

    // // mode=0 to test forward logic
    // reset <=1; a <= 3; b <= 1; I_0 <= 1; mode <= 0; #CLOCK_PERIOD;
    // reset <= 0; #CLOCK_PERIOD;
    // for (i=0;i<4;i=i+1) begin
    //     net_sum[i] = 0;
    // end
    // for (i=0;i<steps;i=i+1) begin
    //     #CLOCK_PERIOD;
    //     for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
    //         net_sum[j] <= net_sum[j] + sum_out[j];
    //     end
    // end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,B=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, b, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b", a+b, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    
    // // mode=0 to test forward logic
    // reset <=1; a <= 7; b <= 1; I_0 <= 1; mode <= 0; #CLOCK_PERIOD;
    // reset <= 0; #CLOCK_PERIOD;
    // for (i=0;i<4;i=i+1) begin
    //     net_sum[i] = 0;
    // end
    // for (i=0;i<steps;i=i+1) begin
    //     #CLOCK_PERIOD;
    //     for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
    //         net_sum[j] <= net_sum[j] + sum_out[j];
    //     end
    // end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,B=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, b, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b", a+b, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});

    // // mode=0 to test forward logic
    // reset <=1; a <= 15; b <= 1; I_0 <= 1; mode <= 0; #CLOCK_PERIOD;
    // reset <= 0; #CLOCK_PERIOD;
    // for (i=0;i<4;i=i+1) begin
    //     net_sum[i] = 0;
    // end
    // for (i=0;i<steps;i=i+1) begin
    //     #CLOCK_PERIOD;
    //     for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
    //         net_sum[j] <= net_sum[j] + sum_out[j];
    //     end
    // end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,B=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, b, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b", a+b, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    

    $display("\nSubtraction: b=s-a");
    // mode=2 to test subtraction
    reset <=1; a <= 3; sum <= 12; I_0 <= 1; mode <= 2; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for (i=0;i<4;i=i+1) begin
        net_sum[i] = 0;
    end
    $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow, I_0, mode, steps, log_tau);
    for (i=0;i<steps;i=i+1) begin
        #CLOCK_PERIOD;
        for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
            net_sum[j] <= net_sum[j] + b_out[j];
        end
        $fdisplay(test_data, "%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow);
    end
    $display("Percentage of cycles where bit was equal to 1:");
    $display("A=%d,Sum=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, sum, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    $display("Expected bit averages: %b.  Results: %b", sum-a, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    

    $display("\nInverse Sum: a+b=s");
    // mode=1 to test inverse sum
    reset <=1; sum <= 12; I_0 <= 1; mode <= 1; #CLOCK_PERIOD; steps=300;
    reset <= 0; #CLOCK_PERIOD;
    for (i=0;i<4;i=i+1) begin
        net_sum[i] = 0;
    end
    $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow, I_0, mode, steps,log_tau);
    for (i=0;i<steps;i=i+1) begin
        #CLOCK_PERIOD;
        for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
            net_sum[j] <= net_sum[j] + b_out[j];
        end
        $fdisplay(test_data, "%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow);
    end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,Sum=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, sum, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b", sum-a, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    

    // // mode=2 to test subtraction
    // reset <=1; a <= 4; sum <= 4; I_0 <= 1; mode <= 2; #CLOCK_PERIOD;
    // reset <= 0; #CLOCK_PERIOD;
    // for (i=0;i<4;i=i+1) begin
    //     net_sum[i] = 0;
    // end
    // for (i=0;i<steps;i=i+1) begin
    //     #CLOCK_PERIOD;
    //     for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
    //         net_sum[j] <= net_sum[j] + b_out[j];
    //     end
    // end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,Sum=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, sum, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b",sum-a, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    
    // // mode=2 to test subtraction
    // reset <=1; a <= 3; sum <= 7; I_0 <= 1; mode <= 2; #CLOCK_PERIOD;
    // reset <= 0; #CLOCK_PERIOD;
    // for (i=0;i<4;i=i+1) begin
    //     net_sum[i] = 0;
    // end
    // for (i=0;i<steps;i=i+1) begin
    //     #CLOCK_PERIOD;
    //     for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
    //         net_sum[j] <= net_sum[j] + b_out[j];
    //     end
    // end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,Sum=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, sum, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b", sum-a, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    
    // // mode=2 to test subtraction
    // reset <=1; a <= 9; sum <= 2; I_0 <= 1; mode <= 2; #CLOCK_PERIOD;
    // reset <= 0; #CLOCK_PERIOD;
    // for (i=0;i<4;i=i+1) begin
    //     net_sum[i] = 0;
    // end
    // for (i=0;i<steps;i=i+1) begin
    //     #CLOCK_PERIOD;
    //     for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
    //         net_sum[j] <= net_sum[j] + b_out[j];
    //     end
    // end
    // $display("Percentage of cycles where bit was equal to 1:");
    // $display("A=%d,Sum=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, sum, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    // $display("Expected bit averages: %b.  Results: %b", sum-a, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    
    $fclose(test_data);
    $stop;
end
endmodule