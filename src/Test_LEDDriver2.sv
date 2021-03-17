module Test_LEDDriver2;
    parameter LEDS  = 50;
    parameter FREQ  = 12_500_000;
    parameter BIN_QTY = 12;
    localparam TB_FREQ = 12_500_000;
    localparam TB_PERIOD =  80ns;

    logic dOut, clkOut;              // outputs to LED
    logic done;                      // comms output to visualizer
    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    logic start;                     // comms input from visualizer
    logic clk, rst;                  // standard inputs

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    // DUT
    LEDDriver2 #(
        .LEDS(LEDS), 
        .FREQ(TB_FREQ),
        .FREQ_DIV(5)
    ) dut (
        .dOut    (dOut   ),
        .clkOut  (clkOut ),
        .done    (done   ),
        .rgb     (rgb    ),
        .LEDCounts(LEDCounts),
        .start   (start  ),
        .clk     (clk    ),
        .rst     (rst    )
    );

    task reset(integer duration); begin
            rst = '1; repeat(duration) @(posedge clk);
            rst = '0;
            start = 1;
        end
    endtask

    task testInputs (input logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] count,
                     input logic [BIN_QTY - 1 : 0][23 : 0] color);
         begin
             rgb = color;
            LEDCounts = count;

            wait(!done);
            wait(done);
         end

    endtask

    initial begin
        reset(10);

        testInputs({'0, 6'd10, 6'd10, 6'd10},{'0,24'hAAAAAA, 24'hF0F0F0F0, 24'hFFFFFF});
        testInputs({'0, 6'd10, 6'd10, 6'd10},{'0,24'hAAAAAA, 24'hF0F0F0F0, 24'hFFFFFF});
        //testInputs({'0},{'0});
        //testInputs({'0},{'0});

        $stop();
    end
endmodule