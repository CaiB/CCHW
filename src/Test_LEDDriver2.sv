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

    // ========================  LEDModel Testing =====================
    // clock and data signals between individual WS2801s. For LED[i], SDIO[i] is the input and SDIO[i+1] is the output
    logic [LEDS:0] SDIO, CKIO;

    logic [LEDS-1:0][23:0] FrameColorContent;
    logic [LEDS-1:0][23:0] FrameColorContentExpected;

    // TODO: Make sure this genvar is not in use is not already in use,
    // if the "automatic" statement works you may not need to change loop iteration variable
    genvar i;

    // since the checkLEDs task is automatic it is okay if j is used elsewhere
    integer j;

    generate
        for ( i = 0; i < LEDS; i++) begin : LEDBar
            LEDModel led (.rgb(FrameColorContent[i]), .SDO(SDIO[i+1]), .CKO(CKIO[i+1]), .SDI(SDIO[i]), .CKI(CKIO[i]));
        end
    endgenerate

    
    // Note: surround with a fork join statement to stop the wait statements from blocking
    task automatic checkLEDs(logic [LEDS-1:0][23:0] ColorContent);
        begin
            $timeformat(-9, 2, " ns");

            FrameColorContentExpected = ColorContent;

            wait(CKIO[0]);
            // TODO: replace with a signal that suggests that the values have been registered (500us after transmisison finished)
            wait(done);
            wait(!done);

            for (j = 0; j < LEDS; j++) begin
                assert(FrameColorContent[j] == FrameColorContentExpected[j]) $display("LED %d at time %d is CORRECT", j, $time);
                    else $display("LED %d at time %d is INCORRECT ; Expected = %6h, Recieved = %6h", j, $time, FrameColorContentExpected[j], FrameColorContent[j]);
            end
        end
    endtask

    assign SDIO[0] = dOut;
    assign CKIO[0] = clkOut;

    // ==================================================================

    initial begin
        $timeformat(-6, 2, " us");

        reset(10);
            
        fork
            testInputs({'0, 6'd10, 6'd10, 6'd10},{'0,24'hAAAAAA, 24'hF0F0F0F0, 24'hFFFFFF});
            checkLEDs({{30{24'hAAAAAA}},{10{24'hF0F0F0F0}},{10{24'hFFFFFF}}});
        join
        
        testInputs({'0, 6'd10, 6'd10, 6'd10},{'0,24'hAAAAAA, 24'hF0F0F0F0, 24'hFFFFFF});
        //testInputs({'0},{'0});
        //testInputs({'0},{'0});

        $stop();
    end
endmodule