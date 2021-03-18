import CCHW::*;
module Test_LV_Driver;
    localparam TB_FREQ = 12_500_000;
    localparam TB_PERIOD =  80ns;
    parameter W = 6;                        // max whole value 63
    parameter D = 10;                       // decimal precision to ~.001
    parameter LEDS  = 50;                   // number of LEDs being driven
    parameter BIN_QTY = 12;
    parameter steadyBright = 'b0;           // False

    // these assume the W and D above, use fixedPointCalculator.py to recalculate if needed
    parameter LEDFloor = 205;               // 0.100... ~ 205 ~ 00011001101 - sets the relative threshold value for amplitudes to be considered 
    parameter LEDLimit = 1023;              // ~1.0 ~ 1023 ~ 1111111111
    parameter SaturationAmplifier = 1638;   // 1.599.. ~ 1638 ~ 1_1111000000
    parameter yellowToRedSlope  = 21824;    // 21.3125 ~  21824 ~  'b10101_0101000000
    parameter redToBlueSlope    = 43648;    // 42.625  ~  41600 ~ 'b101010_1010000000
    parameter blueToYellowSlope = 65472;    // 63.9375 ~ 130944 ~ 'b111111_1111000000

    integer i;

    logic dOut, clkOut;
    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    Note notes [BIN_QTY - 1 : 0];

    logic ld_done, lv_dv;
    logic lv_start;
    logic clk, rst;

    LVDriver DUT (.dOut(dOut), .clkOut(clkOut), .done(ld_done), .notes(notes), .start(lv_start), .clk(clk), .rst(rst));

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    logic [W + D - 1 : 0] testAmplitudes [BIN_QTY - 1 : 0];
    logic [W + D - 1 : 0] testPositions [BIN_QTY - 1 : 0];

    initial begin
        $readmemb("../other/testNotePositions.mem", testPositions);
        $readmemb("../other/testNoteAmplitudes.mem", testAmplitudes);
    end

    task reset(input duration);
        begin
            rst = '1; @(posedge clk);
            repeat(10) @(posedge clk);
            rst = '0;
        end
    endtask

    task runCycle(input logic [W + D - 1 : 0] amplitudes [BIN_QTY - 1 : 0],
                  input logic [W + D - 1 : 0] positions [BIN_QTY - 1 : 0]);
        begin
            lv_start = 1;

            for (i = 0; i < BIN_QTY; i++) begin
                notes[i].amplitude = amplitudes[i];
                notes[i].position = positions[i];
                notes[i].valid = '1;
            end

            wait(!ld_done);
            wait(ld_done);
            lv_start = 0;
        end
    endtask

    initial begin

        reset(10);
        runCycle(testAmplitudes, testPositions);

        $stop();
    end
endmodule