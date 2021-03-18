
module Test_HueCalc;
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

        notePosition_i = 10'b1000000000 * 24;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);


        $stop();
    end

endmodule
