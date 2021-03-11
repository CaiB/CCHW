module HueCalc #(
    parameter D = 10,
    parameter BinsPerOctave  = 24,

    parameter yellowToRedSlope  = 21824,    // 21.3125 ~  21824 ~  'b10101_0101000000
    parameter redToBlueSlope    = 43648,    // 42.625  ~  41600 ~ 'b101010_1010000000
    parameter blueToYellowSlope = 65472     // 63.9375 ~ 130944 ~ 'b111111_1111000000
) (
    output logic [D - 1 : 0] noteHue_o,
    output logic data_v,

    input logic [D - 1 : 0] notePosition_i,
    input logic start, clk, rst
);

    parameter W = $clog2(BinsPerOctave);

    // propogates the start signal
    logic [3:0] valid_delay;

    logic [2:0] comparator, comparator_d1, comparator_d2, comparator_d3;
    logic [W + D - 1 : 0] note, note_d1;
    logic signed [W + D - 1 : 0] noteSub, noteSub_d1;
    logic signed [7 + D + W + D - 1 : 0] noteMult;
    logic signed [D - 1 : 0] noteMult_d1;
    logic [D - 1 : 0] notePreRectified, noteRectified;

    always_comb begin
        // cycle 1
        note = notePosition_i * BinsPerOctave;
        if (note < 8192)       comparator = 3'b001;
        else if (note < 16384) comparator = 3'b010;
        else                   comparator = 3'b100;

        // cycle 2
        noteSub = comparator_d1[2] ? 24576 - note_d1: 8192 - note_d1;

        // cycle 3
        if (comparator_d2[0])       noteMult = noteSub_d1 * yellowToRedSlope;
        else if (comparator_d2[1])  noteMult = noteSub_d1 * redToBlueSlope;
        else                        noteMult = noteSub_d1 * blueToYellowSlope;
        
        // cycle 4
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
            comparator_d1 <= comparator;
            comparator_d2 <= comparator_d1;
            comparator_d3 <= comparator_d2;
            note_d1 <= note;
            noteSub_d1 <= noteSub;

            // bit range max is the concatenation of the bit range maximums of each signal multiplied and 9 less than that
            noteMult_d1 <= noteMult[5 + D + W + D - 1 : 5 + D + W + D - 10]; // take the top 10 bits of the result

            valid_delay <= {valid_delay[2:0], start};
        end
    end

endmodule

module HueCalc_testbench();
    parameter D = 10;
    parameter BinsPerOctave  = 24;
    parameter TB_PERIOD = 100ns;

    parameter yellowToRedSlope  = 21824;    // 21.3125 ~  21824 ~  'b10101_0101000000
    parameter redToBlueSlope    = 43648;    // 42.625  ~  41600 ~ 'b101010_1010000000
    parameter blueToYellowSlope = 65472;    // 63.9375 ~ 130944 ~ 'b111111_1111000000

    logic [D - 1 : 0] noteHue_o;
    logic data_v;

    logic [D - 1 : 0] notePosition_i;
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

        notePosition_i = 10'b0110001000;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);

        notePosition_i = 10'b1011001001;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);

        notePosition_i = 10'b0110100111;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);


        $stop();
    end

endmodule