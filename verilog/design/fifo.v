`timescale 1ns / 1ps
// 16 x 8 FIFO (width = 8 for ASCII, depth = 16 characters)
module fifo(
    input clk, reset_n,
    input we, re,
    input [7:0] din,
    output [7:0] dout,
    output empty, full
    );
    reg [7:0] mem [0:15];
    reg [4:0] wr_ptr, rd_ptr;           // extra MSB distinguishes full from empty

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[3:0] == rd_ptr[3:0]) & (wr_ptr[4] != rd_ptr[4]);
    assign dout  = mem[rd_ptr[3:0]];

    always @(posedge clk, negedge reset_n)
        if (~reset_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (we & ~full) begin
                mem[wr_ptr[3:0]] <= din;
                wr_ptr <= wr_ptr + 1;
            end
            if (re & ~empty)
                rd_ptr <= rd_ptr + 1;
        end
endmodule
