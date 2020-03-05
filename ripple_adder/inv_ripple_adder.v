// `include "uvm_macros.svh"
// `include "uvm_pkg.sv" 
// a, b sum inputs can be set to fix the input to the adder for forward or inverse logic
// pbit_out contains the stochastic values of each bit in the network. One can extract sum from pbit_out[i][3] for each bit i, 
module inv_ripple_adder(clk, reset, mode, I_0, a, b, sum, a_out, b_out, sum_out, overflow);
input reset, clk;
input [1:0] mode;
input [3:0] a, b, I_0, sum;
output reg [3:0] a_out, b_out, sum_out;
output reg overflow;
wire [4:0] pbit_out[3:0];
reg [1:0] a_clamp[3:0], b_clamp[3:0], cin_clamp[3:0], s_clamp[3:0], cout_clamp[3:0]; // 4 x 2bit clamp inputs 

// set full adders according to operating mode
integer i;
always@(*) begin
    // clamped values
    for (i=0;i<=3;i=i+1) begin
        {a_clamp[i][0], b_clamp[i][0], s_clamp[i][0]} = {a[i], b[i], sum[i]}; // assign clamp values to inputs
        {a_out[i], b_out[i], sum_out[i]} = {pbit_out[i][0], pbit_out[i][1], pbit_out[i][3]}; // assign outputs to pbits
        if (i>0) begin
            cin_clamp[i][0] = pbit_out[i-1][4]; // carry in clamped to carry out of previous bits, 0, for first bit
        end else begin
            cin_clamp[i][0] = 1'b0;
        end
        // if (i<3) begin
        //     cout_clamp[i][0] = pbit_out[i+1][2]; // fixes carry out to carry in, except for top bit.  Let's try removing this 
        // end else begin
        //     cout_clamp[i][0] = 1'bx; // carry out of top bit is not fixed
        // end
        cout_clamp[i][0] = 1'bx; // carry out bit will never be fixed
    end

    overflow = pbit_out[3][4]; // overflow is Cout of msb

    // control whether bits are clamped or not
    if (mode==0) begin // input mode, a,b,cin are fixed
        for (i=0;i<=3;i=i+1) begin
            {a_clamp[i][1], b_clamp[i][1], cin_clamp[i][1]} = 3'b111;
            {s_clamp[i][1], cout_clamp[i][1]} = 2'b00;
        end
    end
    //  else if (mode == 1) begin // inverse mode, sum and cout are fixed, a,b,cin are floating
    //     for (i=0;i<=3;i=i+1) begin
    //         {a_clamp[i][1], b_clamp[i][1], cin_clamp[i][1]} = 3'b000;
    //         if (i<3) begin
    //             {s_clamp[i][1], cout_clamp[i][1]} = 2'b11;
    //         end else begin
    //             {s_clamp[i][1], cout_clamp[i][1]} = 2'b10;
    //         end
    //     end
    // end 
    else if (mode == 1) begin // inverse mode, sum, cin fixed.  a,b,couts] are floating
        for (i=0;i<=3;i=i+1) begin
            {a_clamp[i][1], b_clamp[i][1], cout_clamp[i][1]} = 3'b000;
            {s_clamp[i][1], cin_clamp[i][1]} = 2'b11;
        end
    end else begin // subtract mode. b = sum-a
        for (i=0;i<=3;i=i+1) begin
            {a_clamp[i][1], b_clamp[i][1], cin_clamp[i][1], s_clamp[i][1], cout_clamp[i][1]} = 5'b10110; // fix a, sum, cin
        end
    end
    // can add more modes here...the special cases for end bits make it difficult to automate 
end

// 4 full adders connected according to mode

genvar i_gen;
generate
for (i_gen = 0; i_gen < 4; i_gen = i_gen + 1) begin: adders
    inv_full_adder fa(.clk, .reset, .I_0, .a_clamp(a_clamp[i_gen][1:0]),
    .b_clamp(b_clamp[i_gen][1:0]), 
    .cin_clamp(cin_clamp[i_gen][1:0]), 
    .s_clamp(s_clamp[i_gen][1:0]), 
    .cout_clamp(cout_clamp[i_gen][1:0]), 
    .p_bits(pbit_out[i_gen][4:0]));
end
endgenerate
endmodule



`timescale 1ns/1ps
module inv_ripple_adder_tb();
reg reset, clk;
reg [1:0] mode;
reg [3:0] a, b, sum;
reg [3:0] I_0;
wire [3:0] a_out, b_out, sum_out;
wire overflow;

inv_ripple_adder dut(.clk, .reset, .mode, .I_0, .a, .b, .sum, .a_out, .b_out, .sum_out, .overflow);

parameter CLOCK_PERIOD = 2;
initial // Clock setUp
begin
    clk = 0; 
    forever #(CLOCK_PERIOD/2) clk <= ~clk;
end

// reg[3:0] inputs = 4'b000;
integer i; integer j; integer steps = 1000; integer sum_a, sum_b, sum_cin, sum_cout, sum_s; integer net_sum[3:0];
integer test_data;
initial 
begin
    test_data = $fopen("test_data/t1.csv", "w"); // open output file
    if (test_data) begin
        $display("file opened successfully");
    end else begin
        $stop;
    end
    $fdisplay(test_data, "time,A,B,S,OVF,I0,Mode,Steps");

    // mode=0 to test forward logic
    reset <=1; a <= 1; b <= 7; I_0 <= 1; mode <= 0; #CLOCK_PERIOD;
    reset <= 0; #CLOCK_PERIOD;
    for (i=0;i<4;i=i+1) begin
        net_sum[i] = 0;
    end
    $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow, I_0, mode, steps);
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
    $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow, I_0, mode, steps);
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
    reset <=1; sum <= 12; I_0 <= 1; mode <= 1; #CLOCK_PERIOD; steps=10000;
    reset <= 0; #CLOCK_PERIOD;
    for (i=0;i<4;i=i+1) begin
        net_sum[i] = 0;
    end
    $fdisplay(test_data, "%d,%d,%d,%d,%d,%d,%d,%d",$time, a_out, b_out, sum_out, overflow, I_0, mode, steps);
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