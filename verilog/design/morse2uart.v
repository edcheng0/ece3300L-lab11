`timescale 1ns / 1ps
// Lab block diagram: Morse decoder -> ROM -> UART (replaces the FIFO of the previous lab)
module morse2uart
    #(parameter MORSE_TIMER_FINAL_VALUE = 6_999_999)(  // 70 ms Morse time unit
    input clk, reset_n,
    input b,            // Morse key (already debounced)
    output tx           // serial output to the PC
    );
    wire dot, dash, lg, wg;
    morse_decoder_2 #(.TIMER_FINAL_VALUE(MORSE_TIMER_FINAL_VALUE)) DEC(
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

    // ROM address: {count, symbol}, or the "space" address on a word gap
    wire [7:0] addr = wg ? 8'b0111_0000 : {symbol_count, symbol};
    wire [7:0] ascii;
    synch_rom ROM(.clk(clk), .addr(addr), .data(ascii));

    // UART: 650 -> 100 MHz / (651 * 16) = 9600 baud. Receiver unused (rd_uart = 0, rx idle = 1)
    wire tx_full;
    uart UART0(
        .clk(clk), .reset_n(reset_n),
        .r_data(), .rd_uart(1'b0), .rx_empty(), .rx(1'b1),
        .w_data(ascii), .wr_uart(~tx_full & (lg | wg | wg_delayed)),
        .tx_full(tx_full), .tx(tx),
        .TIMER_FINAL_VALUE(11'd650));
endmodule
