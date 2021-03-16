import CCHW::*;

module part1
(
	output logic FPGA_I2C_SCLK, 
	inout FPGA_I2C_SDAT, 
	output logic AUD_XCK, AUD_DACDAT,
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, 

	output logic [9:0] LEDR,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	input logic [9:0] SW,
	input logic [3:0] KEY, 
	input logic CLOCK_50, CLOCK2_50
);
	// Audio-related
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];

	/* Your code goes here */
	parameter BPO = 24;
	parameter OC = 5;
	parameter N = 16;
	parameter TOPSIZE = 8192;
	parameter ND = (N*2)+(OC-1);

	logic clk_12M5, locked;
	PLL PLL12M5 (.refclk(CLOCK_50), .rst(reset), .outclk_0(clk_12M5), .locked);

	// DFT
	logic signed [24:0] rawInput; // audio data with both channels summed
	logic signed [N-1:0] inputSample; // summed audio data, trimmed to fit into DFT input
	assign rawInput = readdata_left + readdata_right;
	assign inputSample = rawInput[23:(24-N)];

	logic unsigned [ND-1:0] outBins [0:(BPO*OC)-1];
	DFT #(.BPO(BPO), .OC(OC), .N(N), .TOPSIZE(TOPSIZE), .ND(ND)) TheDFT(.outBins, .inputSample, .sampleReady(read_ready), .doingRead(read), .clk(clk_12M5), .rst(reset || !locked));

	// NoteFinder
	logic [11:0] NFPeaks;
	logic unsigned [N-1:0] BinsSmall [0:(BPO*OC)-1];
	logic NFStart;
	logic [9:0] SyncedSwitches;
	Note Notes [0:11];
	NoteFinder #(.BPO(BPO), .OCT(OC), .N(N)) TheNoteFinder(.notes(Notes), .peaksOut(NFPeaks), .dftBins(BinsSmall), .minThreshold(SyncedSwitches), .startCycle(NFStart), .clk(clk_12M5), .rst(reset || !locked));

	// Visual outputs
	logic [9:0] InputAbsTrim;
	always_comb
	begin
		if(rawInput[23]) InputAbsTrim = -rawInput[23:14];
		else InputAbsTrim = rawInput[23:14];
		LEDR = { InputAbsTrim[0], InputAbsTrim[1], InputAbsTrim[2], InputAbsTrim[3], InputAbsTrim[4], InputAbsTrim[5], InputAbsTrim[6], InputAbsTrim[7], InputAbsTrim[8], InputAbsTrim[9] };
		HEX0 = {1'b1, {2{~NFPeaks[10]}}, 1'b1, {2{~NFPeaks[11]}}, 1'b1};
		HEX1 = {1'b1, {2{~NFPeaks[8]}}, 1'b1, {2{~NFPeaks[9]}}, 1'b1};
		HEX2 = {1'b1, {2{~NFPeaks[6]}}, 1'b1, {2{~NFPeaks[7]}}, 1'b1};
		HEX3 = {1'b1, {2{~NFPeaks[4]}}, 1'b1, {2{~NFPeaks[5]}}, 1'b1};
		HEX4 = {1'b1, {2{~NFPeaks[2]}}, 1'b1, {2{~NFPeaks[3]}}, 1'b1};
		HEX5 = {Notes[0].position[10], {2{~NFPeaks[0]}}, 1'b1, {2{~NFPeaks[1]}}, 1'b1};
	end

	genvar i;
	generate
		// Small bins
		for(i = 0; i < (BPO*OC); i++)
		begin : MakeSmallBins
			assign BinsSmall[i] = outBins[i][(ND-1):(ND-N)];
		end

		for(i = 0; i < 10; i++)
		begin : MakeSWSyncs
			Synchronizer SWSync(.out(SyncedSwitches[i]), .in(SW[i]), .clk(clk_12M5), .rst(reset || !locked));
		end
	endgenerate

	logic [3:0] DelayLine;
	always_ff @(posedge clk_12M5)
		if(reset || !locked) DelayLine <= '0;
		else DelayLine <= (DelayLine << 1) | read;
	
	assign NFStart = DelayLine[3];
	/* End custom code */
	
	// Audio system
	clock_generator my_clock_gen(CLOCK2_50, reset, AUD_XCK);
	audio_and_video_config cfg(CLOCK_50, reset, FPGA_I2C_SDAT, FPGA_I2C_SCLK);
	audio_codec codec(CLOCK_50, reset, read, write, writedata_left, writedata_right, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, read_ready, write_ready, readdata_left, readdata_right, AUD_DACDAT);
endmodule