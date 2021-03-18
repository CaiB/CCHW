import CCHW::*;

module LVDriver #(
    parameter W = 5,                        // number of whole bits in the fixed point format
    parameter D = 11,                       // number of decimal  bits in the fixed point format - precision to ~.001  
    parameter LEDS  = 50,                   // number of LEDs being driven
    parameter BIN_QTY = 12,                 // number of independant notes being processed
    parameter steadyBright = 'b0,           // (0) use the original amplitudes if they are greater than threshold, 0 otherwise
                                            // (1) use amplitude - threshold value if it is greater than 0, 0 otherwise
    parameter FREQ = 12_000_000,            

    // these assume the W and D above, use fixedPointCalculator.py to recalculate if needed
    parameter LEDFloor = 205,               // 0.100... ~ 205 ~ 00011001101 - sets the relative threshold value for amplitudes to be considered 
    parameter LEDLimit = 2047,              // ~1.0 ~ 2047 ~ 11111111111 - sets the final hue amplitude upper limit 
    parameter SaturationAmplifier = 3277,   // 1.6000.. ~ 3277 ~ 1_10011001101 - scales the hue amplitude up to the LEDLimit
    parameter LEDS_X = 41,                  // 0.02001.. ~ 41 ~ 00000101001 - inverse of LEDS
    parameter yellowToRedSlope  = 43648,    // 21.3125 ~  43648 ~  'b10101_01010000000 ~ 1/48 of hue range (1024) - a slope of the "circular" piecewsie hue mapper
    parameter redToBlueSlope    = 87296,    // 42.625  ~  87296 ~ 'b101010_10100000000 ~ 1/24 of hue range (1024) - a slope of the "circular" piecewise hue mapper
    parameter blueToYellowSlope = 130944     // 63.9375 ~ 130944 ~ 'b111111_11110000000 ~ 1/16 of hue range (1024) - a slope of the "circular" piecewise hue mapper
) (
    output logic dOut, clkOut,
    output logic done,

    input Note notes [BIN_QTY - 1 : 0],
    input logic start,
    input logic clk, rst

);
    // glue logic
    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    logic ld_done, lv_dv;
    logic lv_start;


    assign lv_start = start;
    assign done = ld_done;
    

    LEDDriver2 #(
        .LEDS(LEDS), 
        .FREQ(FREQ),
        .FREQ_DIV(5)
    ) ld_u (
        .dOut    (dOut      ),
        .clkOut  (clkOut    ),
        .done    (ld_done   ),
        .rgb     (rgb       ),
        .LEDCounts(LEDCounts),
        .start   (lv_dv     ),
        .clk     (clk       ),
        .rst     (rst       )
    );


    LinearVisualizer #(
        .W                  (W              ),
        .D                  (D              ),
        .LEDS               (LEDS           ),
        .BIN_QTY            (BIN_QTY        ),
        .steadyBright       (steadyBright   ),
        .LEDFloor           (205            ),
        .LEDLimit           (LEDLimit       ),
        .SaturationAmplifier(SaturationAmplifier),
        .yellowToRedSlope   (yellowToRedSlope   ),
        .redToBlueSlope     (redToBlueSlope     ),
        .blueToYellowSlope  (blueToYellowSlope  )
    ) lv_u (
        .rgb            (rgb            ),
        .LEDCounts      (LEDCounts      ),
        .data_v         (lv_dv          ),
        .notes          (notes          ),
        .start          (lv_start       ),
        .clk            (clk            ),
        .rst            (rst            )
    );

endmodule