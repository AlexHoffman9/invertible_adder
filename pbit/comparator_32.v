module comparator_32(a,b,a_ge_b);
input[31:0] a,b;
output reg a_ge_b;

always@(*) begin
    a_ge_b = a >= b;
end

endmodule