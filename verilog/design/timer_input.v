`timescale 1ns / 1ps
// Free-running timer whose final value is an input (baud rate generator)
module timer_input
    #(parameter BITS = 4)(
    input clk, reset_n,
    input enable,
    input [BITS - 1:0] FINAL_VALUE,
    output done
    );
    reg [BITS - 1:0] Q_reg;
    assign done = (Q_reg == FINAL_VALUE);
    always @(posedge clk, negedge reset_n)
        if (~reset_n)    Q_reg <= 0;
        else if (enable) Q_reg <= done ? 0 : Q_reg + 1;
endmodule
