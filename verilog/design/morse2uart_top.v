`timescale 1ns / 1ps
// Nexys A7-100T top level for the Morse Code Terminal lab
//   CPU_RESETN    : reset (active low)
//   BTNC          : Morse key (hold = dot/dash)
//   LED0          : debounced key (visual feedback)
//   UART_RXD_OUT  : FPGA tx -> USB-UART -> PC terminal (9600 8N1)
module morse2uart_top(
    input clk,              // 100 MHz
    input CPU_RESETN,
    input BTNC,
    output LED0,
    output UART_RXD_OUT
    );
    wire key;
    button B_KEY(.clk(clk), .reset_n(CPU_RESETN), .noisy(BTNC),
        .debounced(key), .p_edge(), .n_edge(), ._edge());

    morse2uart CORE(.clk(clk), .reset_n(CPU_RESETN), .b(key), .tx(UART_RXD_OUT));

    assign LED0 = key;
endmodule
