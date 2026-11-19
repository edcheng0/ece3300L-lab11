`timescale 1ns / 1ps

module morse2ascii_tb();

    localparam T    = 10;           // 10 ns clock
    localparam UNIT = 10;           // clocks per Morse time unit = TIMER_FINAL_VALUE + 1

    reg clk, reset_n, b, re;
    wire [7:0] dout;
    wire empty, full;

    // TIMER_FINAL_VALUE shortened from 6_999_999 so the simulation is short
    morse2ascii #(.TIMER_FINAL_VALUE(9)) uut(
        .clk(clk), .reset_n(reset_n), .b(b), .re(re),
        .dout(dout), .empty(empty), .full(full)
    );

    always begin
        clk = 1'b0; #(T/2);
        clk = 1'b1; #(T/2);
    end

    // key down for 'down' units, then key up for 'up' units
    task key(input integer down, input integer up);
    begin
        b = 1'b1; repeat (down * UNIT) @(negedge clk);
        b = 1'b0; repeat (up   * UNIT) @(negedge clk);
    end
    endtask
    task dot_sym;  input integer gap; key(1, gap); endtask
    task dash_sym; input integer gap; key(4, gap); endtask

    reg [8*6-1:0] expected;
    integer i, errors;
    reg [7:0] exp_char;

    initial begin
        expected = "SOS A "; errors = 0;
        reset_n = 1'b0; b = 1'b0; re = 1'b0;
        @(negedge clk); reset_n = 1'b1;
        repeat (3) @(negedge clk);

        dot_sym(1);  dot_sym(1);  dot_sym(4);     // S
        dash_sym(1); dash_sym(1); dash_sym(4);    // O
        dot_sym(1);  dot_sym(1);  dot_sym(9);     // S + word gap
        dot_sym(1);  dash_sym(9);                 // A + word gap

        // read the FIFO out and compare: expect "SOS A "
        for (i = 0; i < 6; i = i + 1) begin
            exp_char = expected >> (8 * (5 - i));
            if (empty) begin
                $display("FAIL: FIFO empty at char %0d", i);
                errors = errors + 1;
            end else if (dout !== exp_char) begin
                $display("FAIL: char %0d expected %h got %h", i, exp_char, dout);
                errors = errors + 1;
            end else
                $display("ok:   char %0d = %h '%c'", i, dout, dout);
            re = 1'b1; @(negedge clk); re = 1'b0; @(negedge clk);
        end
        if (!empty) errors = errors + 1;
        if (errors == 0) $display("PASS: SOS A decoded correctly");
        else             $display("FAIL: %0d error(s)", errors);
        $finish;
    end

    initial begin
        #200000;
        $display("FAIL: timeout");
        $finish;
    end
endmodule
