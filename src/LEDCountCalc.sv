module LEDCountCalc #(
    parameter W = 6,                        // max whole value 63
    parameter D = 10,                       // decimal precision to ~.001

    parameter LEDS = 50,
    parameter BIN_QTY  = 12
) (
    output logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCount,  // count for the final value doesn't matter
    output logic data_v,

    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_i,
    input logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSumNew_i,
    input logic start, clk, rst
);

    logic [1:0] valid_delay;
    logic [W + D - 1 + $clog2(BIN_QTY) - $clog2(LEDS) : 0] thresholdAmplitude, thresholdAmplitude_d1;

    integer i;

    always_comb begin
        // cycle 1
        thresholdAmplitude = amplitudeSumNew_i / LEDS;

        // cycle 2
        for (i = 0; i < BIN_QTY; i++) begin
            LEDCount[i] = noteAmplitudes_i[i] / thresholdAmplitude_d1;
        end

        data_v = valid_delay[1];

    end

    always_ff @(posedge clk) begin
        if (rst) begin 
            valid_delay = '0;
        end
        else begin
            thresholdAmplitude_d1 <= thresholdAmplitude;
            
            valid_delay <= {valid_delay[0], start};
        end
        
    end

endmodule

module LEDCountCalc_testbench ();

    parameter TB_PERIOD = 100ns;

    parameter W = 6;                       // max whole value 63
    parameter D = 10;                       // decimal precision to ~.001
    parameter LEDS = 50;
    parameter BIN_QTY  = 12;

    integer i;

    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCount;
    logic data_v;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_i;
    logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSumNew_i;
    logic start, clk, rst;

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end
    
    // dut
    LEDCountCalc #(
        .W      (W      ),
        .D      (D      ),
        .LEDS   (LEDS   ),
        .BIN_QTY(BIN_QTY)
    ) dut (
        .LEDCount           (LEDCount           ),
        .data_v             (data_v             ),
        .noteAmplitudes_i   (noteAmplitudes_i   ),
        .amplitudeSumNew_i  (amplitudeSumNew_i  ),
        .start              (start              ),
        .clk                (clk                ),
        .rst                (rst                )
    );

    task test_input();
        begin
        
            noteAmplitudes_i[ 0] = 16'b0000110101001010;
            noteAmplitudes_i[ 1] = 16'b0000000000000000;
            noteAmplitudes_i[ 2] = 16'b0000000000000000;
            noteAmplitudes_i[ 3] = 16'b0000000000000000;
            noteAmplitudes_i[ 4] = 16'b0000000000000000;
            noteAmplitudes_i[ 5] = 16'b0000000101001010;
            noteAmplitudes_i[ 6] = 16'b0000110101001010;
            noteAmplitudes_i[ 7] = 16'b0000000000000000;
            noteAmplitudes_i[ 8] = 16'b0000110101001010;
            noteAmplitudes_i[ 9] = 16'b0000000000000000;
            noteAmplitudes_i[10] = 16'b0000000000000000;
            noteAmplitudes_i[11] = 16'b0000000000000000;
            amplitudeSumNew_i = 22'b0000000010100100101000;

        end
    endtask

    task run();
        begin
            start = '1;
            test_input(); 
            repeat(2) @(posedge clk);
            wait(data_v);

            for (i = 0; i < BIN_QTY - 1; i++) begin
                $display("LEDCount[%2d] : %2d", i, LEDCount[i]);
            end
        end
    endtask 


    initial begin
        rst = 1; repeat(5) @(posedge clk);
        rst = 0;

        run();

        $stop();
    end

endmodule