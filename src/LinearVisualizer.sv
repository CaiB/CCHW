import CCHW::*;

/*  The LinearVisualizer (LV) translates frequency and amplitude information into 
*    color words (24 bit RGB) and computes the amplitude ratios of each frequency
*   The LV is split into 2 multicycle stages with 2 computations happening in parallel
*    in each stage. The individual stages are each 4 cycles long for a total of 8 cycles
*    per valid input
*   The input values are initially registered to allocate a full clock period for every
*    computation
*   The LV can be totally pipelined however additional speed is unnecessary
*   Once the LV outut data is valid it stays valid permenatly, this data simply updates
*    to be more recent every 8 cycles
*
*   TESTING:
*   Testing is best done using ./other/LinearVisualizer.xlsx and ./other/GenerateVisualizerTestData.ps1
*   The ps script generates an array of binary data in two .mem files in ./other/ which can be copy and
*    pasted into the xlsx. The xlsx tracks and computes all of the internal registers and wires so that
*    every component can be thoroughly tested 
*/

module LinearVisualizer #(
    parameter W = 5,                        // number of whole bits in the fixed point format
    parameter D = 11,                       // number of decimal  bits in the fixed point format - precision to ~.001
    parameter LEDS  = 50,                   // number of LEDs being driven
    parameter BIN_QTY = 12,                 // number of independant notes being processed

    parameter steadyBright = 'b0,           // (0) use the original amplitudes if they are greater than threshold, 0 otherwise
                                            // (1) use amplitude - threshold value if it is greater than 0, 0 otherwise

    // =============== Fixed Point Specific Parameters ===============
    // The following parameters are computed based on the above parameters W and D. 
    // While the decimal numbers are actual representations of the fixed point numbers, the binary
    // and integer number representations depend on W and D. To recompute these values use:
    // ./other/fixedPointCalculator.py "Decimal Component" "D" and use as the bottom D bits of the 
    // binary value. The top bits are used as normal if there is a whole number component. The integer
    // representation of this binary number should be used to set the parameter

    parameter LEDFloor = 205,               // 0.100... ~ 205 ~ 00011001101 - sets the relative threshold value for amplitudes to be considered 
    parameter LEDLimit = 2047,              // ~1.0 ~ 2047 ~ 11111111111 - sets the final hue amplitude upper limit 
    parameter SaturationAmplifier = 3277,   // 1.6000.. ~ 3277 ~ 1_10011001101 - scales the hue amplitude up to the LEDLimit
    parameter LEDS_X = 41,                  // 0.02001.. ~ 41 ~ 00000101001 - inverse of LEDS
    parameter yellowToRedSlope  = 43648,    // 21.3125 ~  43648 ~  'b10101_01010000000 ~ 1/48 of hue range (1024) - a slope of the "circular" piecewsie hue mapper
    parameter redToBlueSlope    = 87296,    // 42.625  ~  87296 ~ 'b101010_10100000000 ~ 1/24 of hue range (1024) - a slope of the "circular" piecewise hue mapper
    parameter blueToYellowSlope = 130944     // 63.9375 ~ 130944 ~ 'b111111_11110000000 ~ 1/16 of hue range (1024) - a slope of the "circular" piecewise hue mapper
) (
    output logic [BIN_QTY - 1 : 0][23 : 0] rgb,                     // array of unique color words
    output logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts, // numbers of words associated with the colors
    output logic data_v,                                            // set high when the output data is valid (but not necessarily recent) 

    
    input Note notes [BIN_QTY - 1 : 0],                             // array of packed structs of note frequency positions, their amplitudes and if they're valid
    input logic start,                                              // input registering enable signal 
    input logic clk, rst                                            // system clock and reset
);

    genvar i, j;
    integer k;

    // =============== input data registers ===============
    Note [BIN_QTY - 1 : 0] notes_i;                                 // registered array of packed struct of note frequency positions, their amplitudes and if they're valid
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] amplitudesArray;         // amplitude components of each of the registered notes
    logic start_i;                                                  // start signal captured and held high until a reset
    logic P2Start;                                                  // start signal for the second phase of the LV

    // =============== wire logic between modules in phase 1 and 2 ===============
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] amplitudes, amplitudesFast;
    logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSum;
    logic [BIN_QTY - 1 : 0][D - 2 : 0] hues;

    // =============== done signals from all instantiated modules ===============
    logic ampPreprocessorDone;              
    logic LEDCountDone;                     
    logic [BIN_QTY - 1 : 0] hueCalcDones;   
    logic [BIN_QTY - 1 : 0] colorCalcDones; 

    // -----------------------------  PHASE 1 LOGIC   -----------------------------


    // register and hold the note values whenever start is true
    always_ff @(posedge clk) begin
        if (rst) begin
            notes_i <= '0;
            start_i <= '0;
        end

        else if (start) begin
            for (k = 0; k < BIN_QTY; k++) begin
                notes_i[k].position <= notes[k].position;
                notes_i[k].amplitude <= notes[k].valid ? notes[k].amplitude : '0;   // copy amplitude only if the data is avalid
                amplitudesArray[k] <= notes_i[k].amplitude;
                notes_i[k].valid <= '1;
                start_i <= '1;
            end
        end
    end

    // removes amplitudes below a relative threshold and outputs the original and reduced versions along with the reduced amplitude sum
    AmpPreprocessor #(
        .W              (W              ),
        .D              (D              ),
        .BIN_QTY        (BIN_QTY        ),
        .LEDFloor       (LEDFloor       )
    ) AmpPreprocessor_u (
        .noteAmplitudes_o       (amplitudes             ),
        .noteAmplitudesFast_o   (amplitudesFast         ),
        .amplitudeSumNew_o      (amplitudeSum           ),
        .data_v                 (ampPreprocessorDone    ),
        .noteAmplitudes_i       (amplitudesArray        ),
        .start                  (start_i                ),
        .clk                    (clk                    ),
        .rst                    (rst                    )
    );

    // computes the hue (mapped between 0 and 1023) of each bin given its position
    generate
        for (i = 0; i < BIN_QTY; i++) begin : hue_proc
            HueCalc #(
                .W(W),
                .D(D),
                .BinsPerOctave(BIN_QTY*2)
            ) binHueCalc_u (
                .noteHue_o      (hues[i]            ),
                .data_v         (hueCalcDones[i]    ),
                .notePosition_i (notes_i[i].position),
                .start          (start_i            ),
                .clk            (clk                ),
                .rst            (rst                )
            );
        end
    endgenerate


    // -----------------------------  PHASE 2 LOGIC   -----------------------------

    // phase 2 can only start when all modules in phase 1 are finished
    assign P2Start = &{hueCalcDones, ampPreprocessorDone};

    // computes the amplitude ratios of each frequency and multiplies them by LEDS so that their total adds up to LEDS
    LEDCountCalc #(
        .W      (W      ),
        .D      (D      ),
        .LEDS   (LEDS   ),
        .LEDS_X (LEDS_X ),
        .BIN_QTY(BIN_QTY)
    ) dut (
        .LEDCount           (LEDCounts   ),
        .data_v             (LEDCountDone),
        .noteAmplitudes_i   (amplitudes  ),
        .amplitudeSumNew_i  (amplitudeSum),
        .start              (P2Start     ),
        .clk                (clk         ),
        .rst                (rst         )
    );
    
    // computes the color of each bin given their hue and amplitude
    generate
        for (j = 0; j < BIN_QTY; j++) begin : color_proc
            ColorCalc #(
                .W(W),
                .D(D),
                .SaturationAmplifier(SaturationAmplifier),
                .LEDLimit(LEDLimit),
                .steadyBright(steadyBright)
            ) binColorCalc_u (
                .rgb                (rgb[j]           ),
                .data_v             (colorCalcDones[j]),
                .noteAmplitude_i    (amplitudes[j]    ),
                .noteAmplitudeFast_i(amplitudesFast[j]),
                .noteHue_i          (hues[j]          ),
                .start              (P2Start          ),
                .clk                (clk              ),
                .rst                (rst              )
            );
        end
    endgenerate

    // the output done is true only once all phase 2 modules are done
    assign data_v = &{colorCalcDones, LEDCountDone};

endmodule