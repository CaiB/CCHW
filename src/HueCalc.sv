/*  The HueCalculator maps a note position [0,23.999] to a hue [0,1023] so that its circular (wraps around) to match the color wheel
*   It takes a total of 4 cycles to compute, the cycles together form a sequential computation
*       cycle 0 - calculate the cumulative sum of the amplitudes
*       cycle 1 - compute the relative amplitude threshold
*       cycle 2 - test the amplitudes against the threshold
*       cycle 4 - recompute the cumulative sum with the filtered amplitudes
*
*   The hue computation is difficult to comprehend - the analogous sequential c# code is located at:
*    https://github.com/CaiB/ColorChord.NET/blob/master/ColorChord.NET/Visualizers/VisualizerTools.cs
*    and is contained in the CCtoHex function up until the internal function call to HsvToRgb
*/

module HueCalc #(
    parameter W = 6,                        // number of whole bits in the fixed point format
    parameter D = 10,                       // number of decimal  bits in the fixed point format - precision to ~.001
    parameter BinsPerOctave  = 24,          // upper limit of the note position values

    // =============== Fixed Point Specific Parameters ===============
    // The following parameters are computed based on the above parameters W and D. 
    // See LinearVisualizer.sv : line 24 for instruction on how to recompute
    parameter yellowToRedSlope  = 21824,    // 21.3125 ~  21824 ~  'b10101_0101000000 ~ 1/48 of hue range (1024) - a slope of the "circular" piecewise hue mapper
    parameter redToBlueSlope    = 43648,    // 42.625  ~  41600 ~ 'b101010_1010000000 ~ 1/24 of hue range (1024) - a slope of the "circular" piecewise hue mapper
    parameter blueToYellowSlope = 65472     // 63.9375 ~ 130944 ~ 'b111111_1111000000 ~ 1/16 of hue range (1024) - a slope of the "circular" piecewise hue mapper
) (
    output logic [D - 1 : 0] noteHue_o,     // the resulting hue of the note mapped to a value between 0 and 1023
    output logic data_v,                    // set when the computation is complete

    input logic [W + D - 1 : 0] notePosition_i, // input array of the note frequency positions [0, 23.999]
    input logic start, clk, rst                 // system clock and reset signals
);

    // propogates the start signal so that the done signal goes high after 4 cycles
    logic [3:0] valid_delay;

    // =============== cycle 0 outputs and registers ===============
    logic [2:0] comparator, comparator_d1, comparator_d2, comparator_d3;
    logic [W + D - 1 : 0] note, note_d1;

    // =============== cycle 1 outputs and registers ===============
    logic signed [W + D - 1 : 0] noteSub, noteSub_d1;

    // =============== cycle 2 outputs and registers ===============
    logic signed [7 + D + W + D - 1 : 0] noteMult; // 7 + D component comes from the parameter being up to 17 bits wide !!! THIS MAY CHANGE IF THE PARAMETER DOES!!!
    logic signed [D - 1 : 0] noteMult_d1;

    // =============== cycle 3 outputs ===============
    logic [D - 1 : 0] notePreRectified, noteRectified;

    always_comb begin
        // cycle 0 : comptute which of 3 operations need to be done 
        note = notePosition_i;
        if (note < 8192)       comparator = 3'b001;
        else if (note < 16384) comparator = 3'b010;
        else                   comparator = 3'b100;

        // cycle 1 : compute the subtraction necessary to place the value in the range [-8.00, 15.99]
        noteSub = comparator_d1[2] ? 24576 - note_d1: 8192 - note_d1;

        // cycle 2 : the reuslt of these multiplications together span the full 1023 range of values possible
        if (comparator_d2[0])       noteMult = noteSub_d1 * yellowToRedSlope;
        else if (comparator_d2[1])  noteMult = noteSub_d1 * redToBlueSlope;
        else                        noteMult = noteSub_d1 * blueToYellowSlope;
        
        // cycle 3 : bias the result of the multiplicaiton if needed so that ranges are nonoverlapping and make the value positive
        notePreRectified = comparator_d3[2] ? noteMult_d1 + 'd170 : noteMult_d1;
        noteRectified = notePreRectified[D - 1] ? notePreRectified + 'd1023 : notePreRectified;
        noteHue_o = noteRectified;
        
        data_v = valid_delay[3];
    end

    always_ff @(posedge clk) begin
        if (rst) begin
           valid_delay <= '0;
        end
        else begin
            // register the valus between independant cycles
            comparator_d1 <= comparator;
            comparator_d2 <= comparator_d1;
            comparator_d3 <= comparator_d2;
            note_d1 <= note;
            noteSub_d1 <= noteSub;

            // bit range max is the concatenation of the bit range maximums of each signal multiplied and 9 less than that
            noteMult_d1 <= noteMult[4 + D + W + D - 1 : 4 + D + W + D - 10]; // take the top 10 bits of the result

            valid_delay <= {valid_delay[2:0], start};
        end
    end

endmodule

module HueCalc_testbench();
    parameter W = 6;
    parameter D = 10;
    parameter BinsPerOctave  = 24;
    parameter TB_PERIOD = 100ns;

    parameter yellowToRedSlope  = 21824;    // 21.3125 ~  21824 ~  'b10101_0101000000
    parameter redToBlueSlope    = 43648;    // 42.625  ~  41600 ~ 'b101010_1010000000
    parameter blueToYellowSlope = 65472;    // 63.9375 ~ 130944 ~ 'b111111_1111000000

    logic [D - 1 : 0] noteHue_o;
    logic data_v;

    logic [W + D - 1 : 0] notePosition_i;
    logic start, clk, rst;

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    HueCalc #(
        .D(D),
        .BinsPerOctave      (BinsPerOctave      ),
        .yellowToRedSlope   (yellowToRedSlope   ),
        .redToBlueSlope     (redToBlueSlope     ),
        .blueToYellowSlope  (blueToYellowSlope  )
    ) dut (
        .noteHue_o      (noteHue_o      ),
        .data_v         (data_v         ),
        .notePosition_i (notePosition_i ),
        .start          (start          ),
        .clk            (clk            ),
        .rst            (rst            )
    );

    initial begin
        rst = 1; repeat(5) @(posedge clk);
        rst = 0;

        start = '1;

        notePosition_i = 10'b0100001100 * 24;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);


        $stop();
    end

endmodule