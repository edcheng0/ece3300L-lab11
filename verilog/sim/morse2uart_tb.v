`timescale 1ns / 1ps

module morse2uart_tb();

    localparam T    = 10;               // 10 ns clock
    localparam UNIT = 10;               // clocks per Morse unit = MORSE_TIMER_FINAL_VALUE + 1
    localparam BIT  = 651 * 16 * T;     // one UART bit at 9600 baud (TIMER_FINAL_VALUE = 650)

    reg clk, reset_n, b;
    wire tx;

    // Morse timer shortened from 6_999_999 so the simulation is short (UART stays at 9600 baud)
    morse2uart #(.MORSE_TIMER_FINAL_VALUE(9)) uut(.clk(clk), .reset_n(reset_n), .b(b), .tx(tx));

    always begin
        clk = 1'b0; #(T/2);
        clk = 1'b1; #(T/2);
    end

    // key down for 'down' units, then up for 'up' units
    task key(input integer down, input integer up);
    begin
        b = 1'b1; repeat (down * UNIT) @(negedge clk);
        b = 1'b0; repeat (up   * UNIT) @(negedge clk);
    end
    endtask
    task dot_sym;  input integer gap; key(1, gap); endtask
    task dash_sym; input integer gap; key(4, gap); endtask

    // Drive the key: "SOS A"
    initial begin
        reset_n = 1'b0; b = 1'b0;
        repeat (3) @(negedge clk); reset_n = 1'b1;
        repeat (3) @(negedge clk);
        dot_sym(1);  dot_sym(1);  dot_sym(4);     // S
        dash_sym(1); dash_sym(1); dash_sym(4);    // O
        dot_sym(1);  dot_sym(1);  dot_sym(9);     // S + word gap
        dot_sym(1);  dash_sym(9);                 // A + word gap
    end

    // Receive the serial line (9600 8N1, LSB first) and compare with "SOS A "
    reg [8*6-1:0] expected = "SOS A ";
    reg [7:0] rx_char, exp_char;
    integer i, k, errors = 0;

    initial begin
        for (i = 0; i < 6; i = i + 1) begin
            @(negedge tx);                          // start bit
            #(BIT / 2);                             // middle of start bit
            for (k = 0; k < 8; k = k + 1) begin
                #(BIT); rx_char[k] = tx;            // middle of each data bit
            end
            exp_char = expected >> (8 * (5 - i));
            if (rx_char !== exp_char) begin
                $display("FAIL: char %0d expected %h got %h", i, exp_char, rx_char);
                errors = errors + 1;
            end else
                $display("ok:   char %0d = %h '%c'", i, rx_char, rx_char);
        end
        if (errors == 0) $display("PASS: SOS A sent over UART correctly");
        else             $display("FAIL: %0d error(s)", errors);
        $finish;
    end

    initial begin
        #20_000_000;
        $display("FAIL: timeout");
        $finish;
    end
endmodule
