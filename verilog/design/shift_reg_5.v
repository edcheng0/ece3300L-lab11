`timescale 1ns / 1ps
// 5-bit shift register: shifts left, new bit enters at bit 0
module shift_reg_5(
    input clk, reset_n,
    input shift, SI,
    output reg [4:0] Q
    );
    always @(posedge clk, negedge reset_n)
        if (~reset_n)    Q <= 5'b0;
        else if (shift)  Q <= {Q[3:0], SI};
endmodule
