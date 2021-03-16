import CCHW::*;

module LinearVisualizer #(
    parameter W = 6,                        // max whole value 63
    parameter D = 10,                       // decimal precision to ~.001

    parameter LEDS  = 50,                   // number of LEDs being driven
    parameter BIN_QTY = 12,
    // parameter OctaveBinCount = 24;       // not used

    parameter steadyBright = 'b0,           // True

    // these assume the W and D above, use fixedPointCalculator.py to recalculate if needed
    parameter LEDFloor = 102,               // 0.0996... ~ 102 ~ 0001100110
    parameter LEDLimit = 1023,              // ~1.0 ~ 1023 ~ 1111111111
    parameter SaturationAmplifier = 1638,   // 1.599.. ~ 1638 ~ 1_1111000000

    parameter yellowToRedSlope  = 21824,    // 21.3125 ~  21824 ~  'b10101_0101000000
    parameter redToBlueSlope    = 43648,    // 42.625  ~  41600 ~ 'b101010_1010000000
    parameter blueToYellowSlope = 65472     // 63.9375 ~ 130944 ~ 'b111111_1111000000
) (
    output logic [BIN_QTY - 1 : 0][23 : 0] rgb,
    output logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts,
    output logic data_v,                     // comms input from visualizer
    output logic ampPreprocessorDone, LEDCountDone,
    
    input Note notes [BIN_QTY - 1 : 0],
    input logic start,
    input logic clk, rst
);

    genvar i, j;
    integer k;

    // internal registered versions of the inputs
    Note [BIN_QTY - 1 : 0] notes_i;
    logic start_i;

    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] amplitudesArray;

    // glue logic between instantiations
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] amplitudes, amplitudesFast;
    logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSum;
    logic [BIN_QTY - 1 : 0][D - 1 : 0] hues;
    //logic ampPreprocessorDone;              
    //logic LEDCountDone;                     
    logic [BIN_QTY - 1 : 0] hueCalcDones;   
    logic [BIN_QTY - 1 : 0] colorCalcDones; 

    logic p2_start;

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
                notes_i[k].amplitude <= notes[k].valid ? notes[k].amplitude : '0;
                amplitudesArray[k] <= notes_i[k].amplitude;
                notes_i[k].valid <= '1;
                start_i <= '1;
            end
        end
    end

    // computes the relative amplitudes and their sum
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

    // computes the hue of each bin given its position
    generate
        for (i = 0; i < BIN_QTY; i++) begin : hue_proc
            HueCalc #(
                .D(D),
                .BinsPerOctave(BIN_QTY*2)
            ) binHueCalc_u (
                .noteHue_o      (hues[i]            ),
                .data_v         (hueCalcDones[i]    ),
                .notePosition_i (notes_i[i].position),  // only the decimal component
                .start          (start_i            ),
                .clk            (clk                ),
                .rst            (rst                )
            );
        end
    endgenerate


    // -----------------------------  PHASE 2 LOGIC   -----------------------------

    assign p2_start = &{hueCalcDones, ampPreprocessorDone};

    // computes the number LEDs to be assigned to each bin color
    LEDCountCalc #(
        .W      (W      ),
        .D      (D      ),
        .LEDS   (LEDS   ),
        .BIN_QTY(BIN_QTY)
    ) dut (
        .LEDCount           (LEDCounts   ),
        .data_v             (LEDCountDone),
        .noteAmplitudes_i   (amplitudes  ),
        .amplitudeSumNew_i  (amplitudeSum),
        .start              (p2_start    ),
        .clk                (clk         ),
        .rst                (rst         )
    );
    
    // computes the color of each bin given their hue and amplitude
    generate
        for (j = 0; j < BIN_QTY; j++) begin : color_proc
            ColorCalc #(
                .W(W),
                .D(D),
                .SaturationAmplifier(1638),
                .LEDLimit(1023),
                .steadyBright('0)
            ) binColorCalc_u (
                .rgb                (rgb[j]           ),
                .data_v             (colorCalcDones[j]),
                .noteAmplitude_i    (amplitudes[j]    ),
                .noteAmplitudeFast_i(amplitudesFast[j]),
                .noteHue_i          (hues[j]          ),
                .start              (p2_start         ),
                .clk                (clk              ),
                .rst                (rst              )
            );
        end
    endgenerate

    assign data_v = &{colorCalcDones, LEDCountDone};

endmodule

module LinearVisualizer_testbench();

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
    
    Note [BIN_QTY - 1 : 0] notes;
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
