import CCHW::*;

module part1
(
	output logic FPGA_I2C_SCLK, 
	inout FPGA_I2C_SDAT, 
	output logic AUD_XCK, AUD_DACDAT,
	input logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, 
	inout PS2_CLK, PS2_DAT,

	output logic [9:0] LEDR,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	input logic [9:0] SW,
	input logic [3:0] KEY, 
	input logic CLOCK_50, CLOCK2_50,
	inout logic [35:0] GPIO_0
);
	wire reset = ~KEY[0];

	// Audio
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;

	clock_generator my_clock_gen(CLOCK2_50, reset, AUD_XCK);
	audio_and_video_config cfg(CLOCK_50, reset, FPGA_I2C_SDAT, FPGA_I2C_SCLK);
	audio_codec codec(CLOCK_50, reset, read, write, writedata_left, writedata_right, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, read_ready, write_ready, readdata_left, readdata_right, AUD_DACDAT);

	logic signed [24:0] rawInput; // audio data with both channels summed
	logic signed [15:0] inputSample; // summed audio data, trimmed to fit into DFT input
	assign rawInput = readdata_left + readdata_right;
	assign inputSample = rawInput[23:8];

	// PLL to generate 12.5MHz
	logic clk_12M5, locked;
	PLL PLL12M5 (.refclk(CLOCK_50), .rst(reset), .outclk_0(clk_12M5), .locked);

	// Mouse
	logic MouseLeftRaw, MouseRightRaw, MouseMiddleRaw;
	ps2 Mouse(.start('0), .reset, .CLOCK_50, .PS2_CLK, .PS2_DAT, .button_left(MouseLeftRaw), .button_right(MouseRightRaw), .button_middle(MouseMiddleRaw));

	logic MouseLeft, MouseRight, MouseMiddle;
	PulseExtract PulseMouseL(.pulse(MouseLeft), .signal(MouseLeftRaw), .clk(CLOCK_50), .rst(reset));
	PulseExtract PulseMouseR(.pulse(MouseRight), .signal(MouseRightRaw), .clk(CLOCK_50), .rst(reset));
	PulseExtract PulseMouseM(.pulse(MouseMiddle), .signal(MouseMiddleRaw), .clk(CLOCK_50), .rst(reset));

	// ColorChord
	logic [9:0] SyncedSwitches;
	logic [11:0] NFPeaks;
	logic [15:0] MinThreshold;
	logic SampleReadRaw;

	ColorChordTop CCHW(.peaksForDebug(NFPeaks), .iirConstPeakFilter(SyncedSwitches[4:0]), .minThreshold(MinThreshold), .ledData(GPIO_0[18]), .ledClock(GPIO_0[19]), .doingRead(SampleReadRaw), .inputSample, .sampleReady(read_ready), .clk(clk_12M5), .rst(reset || !locked));

	// Because the CCHW system runs at 12.5MHz, the read signal is high for 4 of the 50MHz clock cycles. This module turns any length back into 1 clock cycle to remedy this.
	PulseExtract ReadPulse(.pulse(read), .signal(SampleReadRaw), .clk(CLOCK_50), .rst(reset));
	
	// Mouse threshold selection
	logic [3:0] ThresholdNum;
	always_ff @(posedge CLOCK_50)
		if(reset) ThresholdNum <= '0;
		else if(MouseLeft && ThresholdNum != '1) ThresholdNum <= ThresholdNum + 1'b1;
		else if(MouseRight && ThresholdNum != '0) ThresholdNum <= ThresholdNum - 1'b1;
	
	assign MinThreshold = (16'b1 << ThresholdNum) - 1'b1;

	// Visual outputs
	logic [9:0] InputAbsTrim; // trimmed, absolute value of input audio, to get an idea of input amplitude
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
		HEX5 = {1'b1, {2{~NFPeaks[0]}}, 1'b1, {2{~NFPeaks[1]}}, 1'b1};
	end

	// Synchronizers for switch inputs
	genvar i;
	generate
		for(i = 0; i < 10; i++)
		begin : MakeSWSyncs
			Synchronizer SWSync(.out(SyncedSwitches[i]), .in(SW[i]), .clk(clk_12M5), .rst(reset || !locked));
		end
	endgenerate
endmodule