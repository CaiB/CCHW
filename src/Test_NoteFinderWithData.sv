import CCHW::*;

`timescale 1 ps / 1 ps
module Test_NoteFinderWithData;
    parameter LEN = 1024;
    localparam N = 16;
    localparam BPO = 24;
    localparam OCT = 5;
    localparam BINS = BPO * OCT;
    localparam FPF = 11;

    logic [N-1:0] InputData [0:LEN-1][0:BINS-1];
    initial $readmemh("../other/nfpeaks.txt", InputData);
    
    Note notes [0:11];
    logic [11:0] peaksOut;
    logic finished;
    logic [4:0] iirConstPeakFilter;
    logic unsigned [N-1:0] dftBins [0:BINS-1];
    logic [15:0] minThreshold;
    logic startCycle;
    logic clk, rst;

    NoteFinder #(.N(N), .BPO(BPO), .OCT(OCT)) DUT(.notes, .peaksOut, .finished, .iirConstPeakFilter, .dftBins, .minThreshold, .startCycle, .clk, .rst);

    real NewPeaks_S4R [0:11], OutNotesR [0:11];
    real LowerMergeBoundR, UpperMergeBoundR;
    assign LowerMergeBoundR = DUT.Stage4.LowerMergeBound * (2.0 ** -FPF);
    assign UpperMergeBoundR = DUT.Stage4.UpperMergeBound * (2.0 ** -FPF);

    genvar i;
    generate
        for(i = 0; i < 12; i++)
        begin
            assign NewPeaks_S4R[i] = (DUT.NewPeaks_S4[i].position * (2.0 ** -FPF));
            assign OutNotesR[i] = notes[i].valid ? (notes[i].position * (2.0 ** -FPF)) : 0.0;
        end
    endgenerate

    initial
    begin
        clk <= '1;
        forever #50 clk <= ~clk;
    end

    task Reset;
        dftBins = '{default:0};
        startCycle = '0;
        iirConstPeakFilter = '0;
        minThreshold = '0;
        rst = '1;
        repeat(5) @(posedge clk);
        @(negedge clk);
        rst = '0; @(posedge clk);
    endtask

    task InsertData(int samples);
        for(int i = samples - 1; i > 0; i--)
        begin
            dftBins = InputData[i];
            startCycle = '1;
            @(posedge clk);
            startCycle = '0;
            repeat(800) @(posedge clk);
            if(i < 20 || i % 500 == 0) $display("Sample %4d finished", i);
            if(i == 20) $display("Slowing output to every 500 samples...");
        end
    endtask

    initial
    begin
        Reset();
        InsertData(LEN);
        $stop;
    end
endmodule