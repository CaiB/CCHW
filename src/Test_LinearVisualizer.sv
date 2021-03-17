import CCHW::*;

module Test_LinearVisualizer;

    parameter W = 6;                        // max whole value 63
    parameter D = 10;                       // decimal precision to ~.001
    parameter LEDS  = 50;                   // number of LEDs being drivern
    parameter BIN_QTY = 12;
    parameter steadyBright = 'b0;
   
    parameter LEDFloor = 102;
    parameter LEDLimit = 1023;
    parameter SaturationAmplifier = 1638;
    parameter yellowToRedSlope  = 21824; 
    parameter redToBlueSlope    = 43648;
    parameter blueToYellowSlope = 65472;

    parameter TB_PERIOD = 100ns;

    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    logic data_v;
    
    Note notes [BIN_QTY - 1 : 0];
    logic start;
    logic clk, rst;

    integer i;


    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    LinearVisualizer #(
        .W                  (W              ),
        .D                  (D              ),
        .LEDS               (LEDS           ),
        .BIN_QTY            (BIN_QTY        ),
        .steadyBright       (steadyBright   ),
        .LEDFloor           (102            ),
        .LEDLimit           (LEDLimit       ),
        .SaturationAmplifier(SaturationAmplifier),
        .yellowToRedSlope   (yellowToRedSlope   ),
        .redToBlueSlope     (redToBlueSlope     ),
        .blueToYellowSlope  (blueToYellowSlope  )
    ) dut (
        .rgb            (rgb            ),
        .LEDCounts      (LEDCounts      ),
        .data_v         (data_v         ),
        .notes          (notes          ),
        .start          (start          ),
        .clk            (clk            ),
        .rst            (rst            )
    );


    logic [W + D - 1 : 0] testAmplitudes [BIN_QTY - 1 : 0];
    logic [W + D - 1 : 0] testPositions [BIN_QTY - 1 : 0];

    initial begin
        $readmemb("../other/testNotePositions.mem", testPositions);
        $readmemb("../other/testNoteAmplitudes.mem", testAmplitudes);
    end

    task reset(input duration);
        begin
            rst = '1;
            repeat(duration) @(posedge clk);
            rst <= '0; @(posedge clk);
        end
    endtask

    task runCycle(input logic [W + D - 1 : 0] amplitudes [BIN_QTY - 1 : 0],
                  input logic [W + D - 1 : 0] positions [BIN_QTY - 1 : 0]);
        begin
            start = 1;

            for (i = 0; i < BIN_QTY; i++) begin
                notes[i].amplitude = amplitudes[i];
                notes[i].position = 24 *positions[i];
                notes[i].valid = '1;
            end

            repeat(10) @(posedge clk);
            start = 0;
        end
    endtask

    initial begin
        reset(10);
        runCycle(testAmplitudes, testPositions);

        $stop();
    end
endmodule