`timescale 1ns / 1ps
// Core of the Lab 11 block diagram (no board I/O: no debouncer / sseg)
module morse2ascii
    #(parameter TIMER_FINAL_VALUE = 6_999_999)(
    input clk, reset_n,
    input b,            // Morse key (already debounced)
    input re,           // pop FIFO
    output [7:0] dout,  // oldest ASCII character
    output empty, full
    );
    wire dot, dash, lg, wg;
    morse_decoder_2 #(.TIMER_FINAL_VALUE(TIMER_FINAL_VALUE)) DEC(
        .clk(clk), .reset_n(reset_n), .b(b),
        .dot(dot), .dash(dash), .lg(lg), .wg(wg));

    reg wg_delayed;
    always @(posedge clk) wg_delayed <= wg;

    // symbol shift register + symbol counter, both cleared after each letter/word
    wire clr_n = reset_n & ~(lg | wg);
    wire [4:0] symbol;
    wire [2:0] symbol_count;
    shift_reg_5 SR(.clk(clk), .reset_n(clr_n), .shift(dot | dash), .SI(dash), .Q(symbol));
    udl_counter #(.BITS(3)) CNT(.clk(clk), .reset_n(clr_n), .enable(dot | dash),
        .up(1'b1), .load(symbol_count == 5), .D(3'd0), .Q(symbol_count));

    // ROM address: {count, symbol}, or the "space" address when wg
    wire [7:0] addr = wg ? 8'b0111_0000 : {symbol_count, symbol};
    wire [7:0] ascii;
    synch_rom ROM(.clk(clk), .addr(addr), .data(ascii));

    fifo FIFO0(.clk(clk), .reset_n(reset_n), .we(~full & (lg | wg | wg_delayed)),
        .re(re), .din(ascii), .dout(dout), .empty(empty), .full(full));
endmodule
