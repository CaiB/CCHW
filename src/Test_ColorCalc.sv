module Test_ColorCalc;

    parameter W = 6;
    parameter D = 10;
    
    parameter TB_PERIOD = 100ns;

    logic [23:0] rgb;
    logic data_v;
    logic [W + D - 1 : 0] noteAmplitude_i;
    logic [W + D - 1 : 0] noteAmplitudeFast_i;
    logic [D - 1 : 0] noteHue_i;
    logic start, clk, rst;

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    ColorCalc #(
        .W(W),
        .D(D),
        .SaturationAmplifier(1638),
        .quantizeToSix('b0000000110),
        .LEDLimit(1023),
        .steadyBright('0)
    ) dut (
        .rgb                (rgb                ),
        .data_v             (data_v             ),
        .noteAmplitude_i    (noteAmplitude_i    ),
        .noteAmplitudeFast_i(noteAmplitudeFast_i),
        .noteHue_i          (noteHue_i          ),
        .start              (start              ),
        .clk                (clk                ),
        .rst                (rst                )
    );

    initial begin
        rst = 1; repeat(5) @(posedge clk);
        rst = 0;
        start = '1;

        noteAmplitude_i = 10'b0101100000;
        noteAmplitudeFast_i = 10'b1011111010;
        noteHue_i = 10'b1111010010;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);

        noteAmplitude_i = 10'b1100011001;
        noteAmplitudeFast_i = 10'b0110101101;
        noteHue_i = 10'b0111110101;


        @(posedge clk);
        @(posedge clk);
        wait(data_v);

        noteAmplitude_i = 10'b1001111010;
        noteAmplitudeFast_i = 10'b0100001110;
        noteHue_i = 10'b0100000000;


        @(posedge clk);
        @(posedge clk);
        wait(data_v);
        
        $stop();
    end
endmodule