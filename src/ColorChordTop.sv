import CCHW::*;

module ColorChordTop
(
    output logic [11:0] peaksForDebug, // The peaks at the 12 note positions just to show on the HEX displays for debugging
    output logic doingRead, // high for 1 clock cycle while we read from the audio buffer
    output logic ledClock, ledData, // output lines to GPIO for LEDs
`ifdef RAM_ASIC
    output logic [4:0] trigROMBinIndex,
    output logic [5:0] trigROMSampleIndex,
    input logic [15:0] sinFromROM, cosFromROM,
`endif
    input logic signed [15:0] inputSample, // the input audio data
    input logic [15:0] minThreshold,
    input logic sampleReady, // set high when there's fresh audio data ready
    input logic clk, rst
);
    localparam BINS_PER_OCTAVE = 24; // How many frequency bins the DFT calculates for each octave (12 notes), must be a multiple of 12
    localparam OCTAVE_COUNT = 5; // How many octaves the DFT should analyze. Only 5 supported without RAM changes.
    localparam DATA_WIDTH = 16; // The size of the input data, and most of the internal signals of the system.
    localparam TOP_MEMORY_DEPTH = 8192; // How many samples long the top octave's memory should be. Only 8192 supported without RAM changes.
    localparam LED_FREQ_DIV = 4; // How many times slower is the output driver compared to the system clock. Limited by DE1's output drive circuits.
    localparam LED_WAIT_MULT = 2; // Wait period between sending frames of LED data = 500us * 2 ^ WaitMultiplier - 1. Must be at least 500us, but above 800us appears to work better.
    localparam LED_QTY = 50; // How many LEDs are connected on the output.
    localparam PEAK_THRES_IIR_CONST = 6; // IIR constant to filter out quiet noise between peaks. Higher is stronger filtering.
    localparam NOTE_IIR = 7; // IIR constant to filter note positions and amplitudes. Higher is stronger filtering.

    localparam TOTAL_BINS = BINS_PER_OCTAVE * OCTAVE_COUNT;
    localparam DFT_BIN_WIDTH = (DATA_WIDTH * 2) + (OCTAVE_COUNT - 1);

    // ==== DFT =====
    logic DoingSampleRead;
    logic unsigned [DFT_BIN_WIDTH-1:0] DFTBins [0:TOTAL_BINS-1];
    assign doingRead = DoingSampleRead;

    DFT #(.BPO(BINS_PER_OCTAVE), .OC(OCTAVE_COUNT), .N(DATA_WIDTH), .TOPSIZE(TOP_MEMORY_DEPTH))
        TheDFT(.outBins(DFTBins), .doingRead(DoingSampleRead), .inputSample, .sampleReady,
`ifdef RAM_ASIC // SAPR uses external ROM, so we need those connections
            .trigROMBinIndex, .trigROMSampleIndex, .sinFromROM, .cosFromROM,
`endif
            .clk, .rst);

    logic unsigned [DATA_WIDTH-1:0] DFTBinsSmall [0:TOTAL_BINS-1]; // Drop some bits of DFT output, we don't need the precision
    genvar i;
    generate
		for(i = 0; i < TOTAL_BINS; i++)
		begin : MakeSmallBins
			assign DFTBinsSmall[i] = DFTBins[i][DFT_BIN_WIDTH - 1 : DFT_BIN_WIDTH - DATA_WIDTH];
		end
    endgenerate

    // ==== NoteFinder ====
    Note notes [0:11];
    logic NoteFinderFinished;

    logic [3:0] DelayLine;
	always_ff @(posedge clk)
		if(rst) DelayLine <= '0;
		else DelayLine <= (DelayLine << 1) | DoingSampleRead;

    NoteFinder #(.N(DATA_WIDTH), .BPO(BINS_PER_OCTAVE), .OCT(OCTAVE_COUNT), .BINS(TOTAL_BINS), .PTIIR(PEAK_THRES_IIR_CONST), .NIIR(NOTE_IIR))
        TheNF(.notes, .peaksOut(peaksForDebug), .minThreshold, .finished(NoteFinderFinished), .dftBins(DFTBinsSmall), .startCycle(DelayLine[3]), .clk, .rst);

    // ==== Linear Visualizer ====
    logic StartLEDDriver;
    logic [11:0][23:0] RGBData;
    logic [11:0][$clog2(LED_QTY)-1:0] LEDCounts;

    LinearVisualizer lv_u (.rgb(RGBData), .LEDCounts(LEDCounts), .data_v(StartLEDDriver), .notes, .start(NoteFinderFinished), .clk, .rst);

    // ==== LED Driver ====
    logic LEDOutputDone;

    LEDDriver2 #(.FREQ_DIV(LED_FREQ_DIV), .WaitMultiplier(LED_WAIT_MULT), .LEDS(LED_QTY))
        OutDriver(.dOut(ledData), .clkOut(ledClock), .done(LEDOutputDone), .rgb(RGBData), .LEDCounts, .start(StartLEDDriver), .clk, .rst);
endmodule