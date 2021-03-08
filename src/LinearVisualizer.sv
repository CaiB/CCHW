module LinearVisualizer #(
    parameter W = 6,                        // max whole value 63
    parameter D = 10,                       // decimal precision to ~.001

    parameter LEDS  = 50,                   // number of LEDs being driven
    parameter BIN_QTY = 12,
    // parameter OctaveBinCount = 24;       // not used

    parameter steadyBright = 'b0,           // True

    // these assume the W and D above, use fixedPointCalculator.py to recalculate if needed
    parameter LEDFloor = 'b0001100110,      // 0.0996... ~ 102 ~ 0001100110
    parameter LEDLimit = 1023,              // ~1.0 ~ 1023 ~ 1111111111
    parameter SaturationAmplifier = 1638,   // 1.599.. ~ 1638 ~ 1_1111000000

    parameter yellowToRedSlope  = 21824,    // 21.3125 ~  21824 ~  'b10101_0101000000
    parameter redToBlueSlope    = 43648,    // 42.625  ~  41600 ~ 'b101010_1010000000
    parameter blueToYellowSlope = 65472     // 63.9375 ~ 130944 ~ 'b111111_1111000000
) (
    output logic [BIN_QTY - 1 : 0][23 : 0] rgb,
    output logic [BIN_QTY - 2 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    output logic start,                     // comms input from visualizer
    
    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes,
    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] notePositions,
    input logic done,
    input logic clk, rst
);

    genvar i, j;

    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] amplitudes, amplitudesFast;
    logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSum;
    logic [BIN_QTY - 1 : 0][D - 1 : 0] hues;

    // TODO: integrate start and done into the logic
    assign start = '0;

    // computes the relative amplitudes and their sum
    AmpPreprocessor #(
        .W              (W              ),
        .D              (D              ),
        .BIN_QTY        (BIN_QTY        ),
        .LEDFloor       (LEDFloor       )
    ) AmpPreprocessor_u (
        .noteAmplitudes_o       (noteAmplitudes_o       ),
        .noteAmplitudesFast_o   (noteAmplitudesFast_o   ),
        .amplitudeSumNew_o      (amplitudeSumNew_o      ),
        .done                   (                       ),
        .noteAmplitudes_i       (noteAmplitudes         ),
        .clk                    (clk                    ),
        .rst                    (rst                    )
    );

    // computes the hue of each bin given its position
    generate
        for (i = 0; i < BIN_QTY; i++) begin : hue_proc
            HueCalc #(
                .D(D),
                .BinsPerOctave      (BIN_QTY*2)
            ) binHueCalc_u (
                .noteHue_o      (noteHue_o       ),
                .done           (                ),
                .notePosition_i (notePositions[i]),
                .clk            (clk             ),
                .rst            (rst             )
            );
        end
    endgenerate

    // computes the number LEDs to be assigned to each bin color
    LEDCountCalc #(
        .W      (W      ),
        .D      (D      ),
        .LEDS   (LEDS   ),
        .BIN_QTY(BIN_QTY)
    ) dut (
        .LEDCount           (LEDCounts   ),
        .done               (            ),
        .noteAmplitudes_i   (amplitudes  ),
        .amplitudeSumNew_i  (amplitudeSum),
        .clk                (clk         ,
        .rst                (rst         )
    );
    
    // computes the color of each bin given their hue and amplitude
    generate
        for (j = 0; j < BIN_QTY; i++) begin : color_proc
            ColorCalc #(
                .W(W),
                .D(D),
                .SaturationAmplifier(1638),
                .LEDLimit(1023),
                .steadyBright('0)
            ) binColorCalc_u (
                .rgb                (rgb           ),
                .done               (              ),
                .noteAmplitude_i    (amplitudes    ),
                .noteAmplitudeFast_i(amplitudesFast),
                .noteHue_i          (hues          ),
                .clk                (clk           ),
                .rst                (rst           )
            );
        end
    endgenerate



endmodule

module LinearVisualizer_testbench();
    parameter W = 6;                        // max whole value 63
    parameter D = 10;                       // decimal precision to ~.001
    parameter LEDS  = 50;                   // number of LEDs being drivern
    parameter BIN_QTY = 12;

    logic [(24*LEDS)-1:0] led_rgb;  // data input from visualizer
    logic start;                    // comms input from visualizer
    
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] notePositions;
    logic done;
    logic clk, rst;

    LinearVisualizer #(
        .W              (W              ),
        .D              (D              ),
        .LEDS           (LEDS           ),
        .BIN_QTY        (BIN_QTY        ),
        .steadyBright   ('b1            ),
        .LEDFloor       ('b0001100110   ),
        .LEDLimitWhl    ('b000001       ),
        .LEDLimitDec    ('b0000000000   ),
        .SatAmpWhl      ('b000001       ),
        .SatAmpDec      ('b1001100110   )  
    ) dut (
        .led_rgb        (led_rgb        ),
        .start          (start          ),
        .noteAmplitudes (noteAmplitudes ),
        .notePositions  (notePositions  ),
        .done           (done           ),
        .clk            (clk            ),
        .rst            (rst            )
    );
    

    initial begin


        #100ps;
    end
endmodule
