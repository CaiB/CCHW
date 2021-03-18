module Test_ColorCalc;

    parameter W = 5;
    parameter D = 11;
    
    parameter TB_PERIOD = 100ns;

    logic [23:0] rgb;
    logic data_v;
    logic [W + D - 1 : 0] noteAmplitude_i;
    logic [W + D - 1 : 0] noteAmplitudeFast_i;
    logic [D - 2 : 0] noteHue_i;
    logic start, clk, rst;

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    ColorCalc #(
        .W(W),
        .D(D)
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

        noteAmplitude_i = 39296;
        noteAmplitudeFast_i = 65535;
        noteHue_i = 170;

        @(posedge clk);
        @(posedge clk);
        wait(data_v);
        
        $stop();
    end
endmodule