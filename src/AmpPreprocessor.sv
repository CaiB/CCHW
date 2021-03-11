module AmpPreprocessor #(
    parameter W = 6,                        // max whole value 63
    parameter D = 10,                       // decimal precision to ~.001

    parameter BIN_QTY  = 12,
    parameter LEDFloor = 'b0001100110       // 0.0996... 
) (
    output logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_o,
    output logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudesFast_o,
    output logic [W + D - 1 + $clog2(BIN_QTY): 0] amplitudeSumNew_o,
    output logic data_v,

    input logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes_i,
    input logic start, clk, rst
);
    localparam WIDTH = W + D - 1;

    integer i, j, k;

    // propogates the start signal
    logic [3:0] valid_delay;
    
    logic [WIDTH + $clog2(BIN_QTY) : 0] amplitudeSum, amplitudeSum_d1;
    
    logic [WIDTH + $clog2(BIN_QTY) + 10 : 0] threshold_tmp;
    logic [WIDTH + $clog2(BIN_QTY) : 0] threshold, threshold_d1;

    
    logic [BIN_QTY - 1 : 0][WIDTH : 0] noteAmplitudesReduced;
    logic [BIN_QTY - 1 : 0][WIDTH : 0] noteAmplitudesFast;
    logic [WIDTH + $clog2(BIN_QTY) : 0] amplitudeSumNew;


    always_comb begin
        // cycle 0: accmulation
        amplitudeSum = 'd0;
        for (i = 0; i < BIN_QTY; i++) begin
            amplitudeSum += noteAmplitudes_i[i];
        end

        // cycle 1: multiplicaiton with a constant
        threshold_tmp = (amplitudeSum_d1 * LEDFloor);
        threshold = threshold_tmp[WIDTH + $clog2(BIN_QTY) + 10 : 10];

        // cycle 2: subtraction, muxing
        for (j = 0; j < BIN_QTY; j++) begin
            noteAmplitudesReduced[j] = {{$clog2(BIN_QTY){1'b0}}, noteAmplitudes_i[j]} - threshold_d1;

            noteAmplitudesFast[j] = noteAmplitudesReduced[j][WIDTH] ? '0 : noteAmplitudes_i[j];
            noteAmplitudesReduced[j] = noteAmplitudesReduced[j][WIDTH] ? '0 : noteAmplitudesReduced[j];
        end

        // cycle 3 accumulation
        amplitudeSumNew = 'd0;
        for (k = 0; k < BIN_QTY; k++) begin
            amplitudeSumNew += noteAmplitudesReduced[k];
        end

        data_v = valid_delay[3];
        
        noteAmplitudes_o = noteAmplitudesReduced;
        noteAmplitudesFast_o = noteAmplitudesFast;
        amplitudeSumNew_o = amplitudeSumNew;
    end

    // pass signals between each cycle stage
    always_ff @(posedge clk) begin
        if (rst) begin
            valid_delay <= '0;
        end 
        else begin
            amplitudeSum_d1 <= amplitudeSum;
            threshold_d1    <= threshold;

            valid_delay <= {valid_delay[2:0], start};
        end
    end


endmodule

module AmpPreprocessor_testbench();
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