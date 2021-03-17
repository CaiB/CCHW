`timescale 1 ps / 1 ps
module Test_FullSystem;
    logic unsigned [11:0] peaksForDebug;
    logic signed [15:0] inputSample;
    logic sampleReady, doingRead, ledClock, ledData;
    logic clk, rst;

    ColorChordTop DUT(.peaksForDebug, .doingRead, .ledClock, .ledData, .inputSample, .iirConstPeakFilter('d3), .minThreshold('0), .sampleReady, .clk, .rst);

    parameter LEN = 9000;
    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);

    real OutNotesR [0:11];

    genvar i;
    generate
        for(i = 0; i < 12; i++)
        begin
            assign OutNotesR[i] = DUT.notes[i].valid ? (DUT.notes[i].position * (2.0 ** -11)) : 0.0;
        end
    endgenerate

    initial
    begin
        clk <= '1;
        forever #100 clk <= ~clk;
    end

    task Reset;
        inputSample = '0;
        sampleReady = '0;
        rst = '1;
        repeat(5) @(posedge clk);
        rst = '0; @(posedge clk);
    endtask

    task InsertData(int samples);
        for(int i = 0; i < samples; i++)
        begin
            sampleReady = '1;
            inputSample = InputData[i];
            @(posedge clk);
            sampleReady = '0;
            repeat(250) @(posedge clk);
            if(i < 20 || i % 10 == 0) $display("Sample %4d finished", i);
        end
    endtask

    initial
    begin
        Reset();
        InsertData(LEN);
        $stop;
    end
endmodule