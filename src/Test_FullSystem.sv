`timescale 1 ps / 1 ps
module Test_FullSystem;
    logic unsigned peaksOut [0:11];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic clk, rst;

    ColorChordTop DUT(.peaksOut, .inputSample, .sampleReady, .clk, .rst);

    parameter LEN = 9000;
    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);

    real RegPeakPositionsR [0:11];

    localparam FPF = 11;
    generate
        for(genvar i = 0; i < 12; i++)
        begin
            assign RegPeakPositionsR[i] = peaksOut[i] ? (DUT.TheNF.RegPeakPositions[i] * (2.0 ** -FPF)) : 'x;
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

            //for(int j = 0; j < BINCOUNT; j++) FileLine = $sformatf("%s%0d,", FileLine, outBins[j]);
            //$fwrite(FileHandle, "%s\n", FileLine);
            //FileLine = "";
        end
    endtask

    initial
    begin
        //FileHandle = $fopen("dftoutput.csv", "w");

        Reset();
        InsertData(LEN);

        //$fclose(FileHandle);
        $stop;
    end
endmodule