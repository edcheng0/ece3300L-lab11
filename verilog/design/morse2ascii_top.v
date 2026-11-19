`timescale 1ns / 1ps
// Nexys A7-100T top level for Lab 11 (Morse to ASCII)
//   CPU_RESETN : reset (active low)
//   BTNC       : Morse key (hold = dot/dash)
//   BTNU       : read next character out of the FIFO
//   LED0       : FIFO empty
//   Seven-seg  : ASCII code of the oldest character, in hex (2 digits, AN1:AN0)
module morse2ascii_top(
    input clk,              // 100 MHz
    input CPU_RESETN,
    input BTNC, BTNU,
    output LED0,
    output [6:0] seg,       // {CG,CF,CE,CD,CC,CB,CA}, active low
    output DP,
    output [7:0] AN         // active low
    );

    wire key, re_level, re;
    button B_KEY(.clk(clk), .reset_n(CPU_RESETN), .noisy(BTNC),
        .debounced(key), .p_edge(), .n_edge(), ._edge());
    button B_RE (.clk(clk), .reset_n(CPU_RESETN), .noisy(BTNU),
        .debounced(re_level), .p_edge(re), .n_edge(), ._edge());   // one pulse per press

    wire [7:0] dout;
    wire empty, full;
    morse2ascii CORE(.clk(clk), .reset_n(CPU_RESETN), .b(key), .re(re),
        .dout(dout), .empty(empty), .full(full));

    assign LED0 = empty;

    // ---- 2-digit multiplexed hex display (~1.5 kHz refresh) ----
    reg [16:0] refresh = 0;
    always @(posedge clk) refresh <= refresh + 1;
    wire sel = refresh[16];
    wire [3:0] nib = sel ? dout[7:4] : dout[3:0];

    reg [6:0] s;
    always @(*)
        case (nib)
            4'h0: s = 7'b1000000;  4'h1: s = 7'b1111001;
            4'h2: s = 7'b0100100;  4'h3: s = 7'b0110000;
            4'h4: s = 7'b0011001;  4'h5: s = 7'b0010010;
            4'h6: s = 7'b0000010;  4'h7: s = 7'b1111000;
            4'h8: s = 7'b0000000;  4'h9: s = 7'b0010000;
            4'hA: s = 7'b0001000;  4'hB: s = 7'b0000011;
            4'hC: s = 7'b1000110;  4'hD: s = 7'b0100001;
            4'hE: s = 7'b0000110;  4'hF: s = 7'b0001110;
        endcase

    assign seg = empty ? 7'b1111111 : s;          // blank when FIFO is empty
    assign AN  = ~(8'b0000_0001 << sel);          // AN0 or AN1 on
    assign DP  = 1'b1;
endmodule
