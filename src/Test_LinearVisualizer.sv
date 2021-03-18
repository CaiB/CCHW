import CCHW::*;

module Test_LinearVisualizer;

    parameter W = 5;
    parameter D = 11;
    parameter LEDS = 50;
    parameter BIN_QTY = 12;
    parameter TB_PERIOD = 100ns;

    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    logic data_v;
    
    Note notes [BIN_QTY - 1 : 0];
    logic start;
    logic clk, rst;

    integer i;


    // clock setup
    initial begin
        clk = '0;
        forever #(TB_PERIOD/2) clk = ~clk;
    end

    LinearVisualizer #(
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
                notes[i].position = positions[i];
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