`timescale 1ns / 1ps
// Behavioral replacement for the Vivado "FIFO Generator" IP used in uart.v
// (8 bits wide, 16 deep, first-word-fall-through, synchronous reset).
// With this file in the project you do NOT need to generate the IP.
module fifo_generator_0(
    input clk, srst,
    input [7:0] din,
    input wr_en, rd_en,
    output [7:0] dout,
    output full, empty
    );
    reg [7:0] mem [0:15];
    reg [4:0] wr_ptr, rd_ptr;
    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[3:0] == rd_ptr[3:0]) & (wr_ptr[4] != rd_ptr[4]);
    assign dout  = mem[rd_ptr[3:0]];
    always @(posedge clk)
        if (srst) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            if (wr_en & ~full) begin
                mem[wr_ptr[3:0]] <= din;
                wr_ptr <= wr_ptr + 1;
            end
            if (rd_en & ~empty)
                rd_ptr <= rd_ptr + 1;
        end
endmodule
