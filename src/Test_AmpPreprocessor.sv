module Test_AmpPreprocessor;
    parameter W = 6;                        // max whole value 63
    parameter D = 10;                       // decimal precision to ~.001
    parameter BIN_QTY = 12;
    parameter TB_PERIOD = 100ns;

    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_o;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudesFast_o;
    logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSumNew_o;
    logic data_v;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_i;
    logic start;
    logic clk;
    logic rst;

    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    AmpPreprocessor #(
        .W              (W              ),
        .D              (D              ),
        .BIN_QTY        (BIN_QTY        ),
        .LEDFloor       ('b0001100110   )
    ) dut (
        .noteAmplitudes_o       (noteAmplitudes_o       ),
        .noteAmplitudesFast_o   (noteAmplitudesFast_o   ),
        .amplitudeSumNew_o      (amplitudeSumNew_o      ),
        .data_v                 (data_v                 ),
        .noteAmplitudes_i       (noteAmplitudes_i       ),
        .start                  (start                  ),
        .clk                    (clk                    ),
        .rst                    (rst                    )
    );

    task test_input();
        begin
        
            noteAmplitudes_i[ 0] = 16'b0001110000000000;
            noteAmplitudes_i[ 1] = 16'b0010000000000000;
            noteAmplitudes_i[ 2] = 16'b0001010000000000;
            noteAmplitudes_i[ 3] = 16'b0000000000000000;
            noteAmplitudes_i[ 4] = 16'b0000100000000000;
            noteAmplitudes_i[ 5] = 16'b0000100000000000;
            noteAmplitudes_i[ 6] = 16'b0000100000000000;
            noteAmplitudes_i[ 7] = 16'b0001110000000000;
            noteAmplitudes_i[ 8] = 16'b0001000000000000;
            noteAmplitudes_i[ 9] = 16'b0001100000000000;
            noteAmplitudes_i[ 10] = 16'b0001000000000000;
            noteAmplitudes_i[ 11] = 16'b0000010000000000;


        end
    endtask

    task run();
        begin
            start = '1;

           test_input(); 
           repeat(2) @(posedge clk);
           wait(data_v);
        end
    endtask 

    initial begin
        rst = 1; repeat(5) @(posedge clk);
        rst = 0;
        run();
        run();
        run();
        $stop;

        #100ps;
    end
endmodule