module inv_ripple_adder_annealed(clk, reset, mode, update_mode, a, b, sum, a_out, b_out, sum_out, overflow, log_tau, I_min, I_max);
input reset, clk, update_mode;
input [1:0] mode;
input [3:0] a, b, sum;
input [3:0] log_tau, I_min, I_max;
output [3:0] a_out, b_out, sum_out;
output overflow;
wire [3:0] I_0;

inv_ripple_adder dut(.clk, .reset, .mode, .I_0, .update_mode, .a, .b, .sum, .a_out, .b_out, .sum_out, .overflow);

annealer ann(.clk, .reset, .log_tau, .I_min, .I_max, .I_0);

endmodule



`timescale 1ns/1ps
module inv_ripple_adder_annealed_tb();
reg reset, clk, update_mode;
reg [1:0] mode;
reg [3:0] a, b, sum;
reg [3:0] I_0;
wire [3:0] a_out, b_out, sum_out;
wire overflow;
reg[3:0] log_tau, I_min, I_max;

inv_ripple_adder_annealed dut(.clk, .reset, .mode, .update_mode, .a, .b, .sum, .a_out, .b_out, .sum_out, .overflow, .log_tau, .I_min, .I_max);

parameter CLOCK_PERIOD = 10;
initial // Clock setUp
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

// reg[3:0] inputs = 4'b000;
integer i; integer j; integer steps = 1000; integer sum_a, sum_b, sum_cin, sum_cout, sum_s; integer net_sum[3:0];
integer test_data; integer offset=0;

task RUN_TEST;
    integer i,j;
    integer offset;

    begin
        offset = $time;
        for (i=0;i<4;i=i+1) begin
            net_sum[i] = 0;
        end
        $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",0, a_out, b_out, sum_out, overflow, I_min, mode, steps, log_tau, update_mode);
        for (i=0;i<steps;i=i+1) begin
            #CLOCK_PERIOD;
            for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
                if (mode==0) begin // keep track of floating value
                    net_sum[j] <= net_sum[j] + sum_out[j];
                end else begin
                    net_sum[j] <= net_sum[j] + b_out[j];
                end
            end
            $fdisplay(test_data, "%d,%d,%d,%d,%d",$time-offset, a_out, b_out, sum_out, overflow);
        end
    end
endtask

initial 
begin
    test_data = $fopen("test_data/t1.csv", "w"); // open output file
    if (test_data) begin
        $display("file opened successfully");
    end else begin
        $stop;
    end
    $fdisplay(test_data, "time,A,B,S,OVF,I_0,Mode,Steps,LogTau,Update");

    // mode=0 to test forward logic parallel
    reset <=1; update_mode<=1; a <= 1; b <= 7; mode <= 0; I_min<=4'b0010; I_max<=4'b1111; log_tau<=8; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    // start task
    // RUN_TEST;
    $display("Percentage of cycles where bit was equal to 1:");
    $display("A=%d,B=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, b, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    $display("Expected bit averages: %b.  Results: %b", a+b, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    
    
    // mode=0 to test forward logic sequential
    reset <=1; update_mode<=0; a <= 1; b <= 7; mode <= 0; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    // RUN_TEST;
    $display("Percentage of cycles where bit was equal to 1:");
    $display("A=%d,B=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, b, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    $display("Expected bit averages: %b.  Results: %b", a+b, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});


    $display("\nSubtraction: b=s-a");
    // mode=2 to test subtraction
    reset <=1;update_mode<=1; a <= 3; sum <= 12; mode <= 2; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    // RUN_TEST;
    $display("Percentage of cycles where bit was equal to 1:");
    $display("A=%d,Sum=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, sum, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    $display("Expected bit averages: %b.  Results: %b", sum-a, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    
    // mode=2 to test subtraction
    reset <=1; update_mode<=0; a <= 3; sum <= 12; mode <= 2; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    RUN_TEST;
    $display("Percentage of cycles where bit was equal to 1:");
    $display("A=%d,Sum=%d: Bit percentages: %d%%, %d%%, %d%%, %d%% after %d cycles", a, sum, net_sum[3]*100/steps, net_sum[2]*100/steps, net_sum[1]*100/steps, net_sum[0]*100/steps, steps);
    $display("Expected bit averages: %b.  Results: %b", sum-a, {net_sum[3]*1.0/steps>0.5,net_sum[2]*1.0/steps>0.5,net_sum[1]*1.0/steps>0.5,net_sum[0]*1.0/steps>0.5});
    


    $display("\nInverse Sum: a+b=s");
    // mode=1 to test inverse sum
    reset <=1; update_mode<=1; sum <= 12; mode <= 1; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    // RUN_TEST;

    // mode=1 to test inverse sum
    reset <=1; update_mode<=0; sum <= 12; mode <= 1; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    // RUN_TEST;
    
    $fclose(test_data);
    $stop;
end
endmodule
// // failed task attempt. worked with global variables (shrug emoji)
// task TEST_LOOP;
//     input overflow, update_mode;
//     input [1:0] mode;
//     input [3:0] a_out, b_out, sum_out, I_min;
//     input integer steps, log_tau;
//     output integer net_sum[3:0];

//     integer i,j;
//     integer offset;

//     begin
//         offset = $time;
//         for (i=0;i<4;i=i+1) begin
//             net_sum[i] = 0;
//         end
//         $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",0, a_out, b_out, sum_out, overflow, I_min, mode, steps, log_tau, update_mode);
//         for (i=0;i<steps;i=i+1) begin
//             #CLOCK_PERIOD;
//             for (j=0;j<4;j=j+1) begin // compute avg of each bit of adder sum
//                 net_sum[j] <= net_sum[j] + sum_out[j];
//             end
//             $fdisplay(test_data, "%d,%d,%d,%d,%d",$time-offset, a_out, b_out, sum_out, overflow);
//         end
//     end
// endtask