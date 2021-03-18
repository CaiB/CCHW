module Test_LEDCountCalc;
    parameter TB_PERIOD = 100ns;

    parameter W = 5;                       // max whole value 63
    parameter D = 11;                       // decimal precision to ~.001
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
            noteAmplitudes_i[ 0] = 16'b1001100110000000;
            noteAmplitudes_i[ 1] = 16'b1001100110000000;
            noteAmplitudes_i[ 2] = 16'b1001100110000000;
            noteAmplitudes_i[ 3] = 16'b1001100110000000;
            noteAmplitudes_i[ 4] = 16'b0000000000000000;
            noteAmplitudes_i[ 5] = 16'b0000000000000000;
            noteAmplitudes_i[ 6] = 16'b0000000000000000;
            noteAmplitudes_i[ 7] = 16'b0000000000000000;
            noteAmplitudes_i[ 8] = 16'b0000000000000000;
            noteAmplitudes_i[ 9] = 16'b0000000000000000;
            noteAmplitudes_i[10] = 16'b0000000000000000;
            noteAmplitudes_i[11] = 16'b0000000000000000;
            amplitudeSumNew_i = 22'b0000100110011000000000;

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