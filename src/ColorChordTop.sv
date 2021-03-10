module ColorChordTop
(
    output logic unsigned peaksOut [0:11],
    input logic signed [15:0] inputSample,
    input logic sampleReady,
    input logic clk, rst
);
    localparam BINS_PER_OCTAVE = 24;
    localparam OCTAVE_COUNT = 5;
    localparam DATA_WIDTH = 16;
    localparam TOP_MEMORY_DEPTH = 8192;
    localparam TOTAL_BINS = BINS_PER_OCTAVE * OCTAVE_COUNT;

    logic DoingSampleRead;
    logic unsigned [35:0] DFTBins [0:TOTAL_BINS-1]; // TODO Parameterize
    logic unsigned [DATA_WIDTH-1:0] DFTBinsSmall [0:TOTAL_BINS-1];

    DFT #(.BPO(BINS_PER_OCTAVE), .OC(OCTAVE_COUNT), .N(DATA_WIDTH), .TOPSIZE(TOP_MEMORY_DEPTH))
        TheDFT(.outBins(DFTBins), .doingRead(DoingSampleRead), .inputSample, .sampleReady, .clk, .rst);

    NoteFinder #(.N(DATA_WIDTH), .BPO(BINS_PER_OCTAVE), .OCT(OCTAVE_COUNT), .BINS(BINS_PER_OCTAVE * OCTAVE_COUNT))
        TheNF(.peaksOut, .dftBins(DFTBinsSmall), .startCycle(DoingSampleRead), .clk, .rst);

    generate
		// Small bins
		for(genvar i = 0; i < TOTAL_BINS; i++)
		begin : MakeSmallBins
			assign DFTBinsSmall[i] = DFTBins[i][35:20]; // TODO parameterize
		end
    endgenerate
endmodule