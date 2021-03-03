module ColorChordTop
(
    output logic unsigned [35:0] outBins [0:119],
    input logic signed [15:0] inputSample,
    input logic clk, rst
);
    logic DoingSampleRead;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(512)) TheDFT(.outBins, .doingRead(DoingSampleRead), .inputSample, .sampleReady, .clk, .rst);
endmodule