/*This module loads data into the TRDB LCM screen's control registers 
 * after system reset. 
 * 
 * Inputs:
 *   CLOCK_50 		- FPGA on board 50 MHz clock
 *   CLOCK2_50  	- FPGA on board 2nd 50 MHz clock
 *   KEY 			- FPGA on board pyhsical key switches
 *   FPGA_I2C_SCLK 	- FPGA I2C communication protocol clock
 *   FPGA_I2C_SDAT  - FPGA I2C communication protocol data
 *   AUD_XCK 		- Audio CODEC data
 *   AUD_DACLRCK 	- Audio CODEC data
 *   AUD_ADCLRCK 	- Audio CODEC data
 *   AUD_BCLK 		- Audio CODEC data
 *   AUD_ADCDAT 	- Audio CODEC data
 *
 * Output:
 *   AUD_DACDAT 	- output Audio CODEC data
 */
module part1 (
	CLOCK_50, 
	CLOCK2_50, 
	KEY, 
	FPGA_I2C_SCLK, 
	FPGA_I2C_SDAT, 
	AUD_XCK, 
	AUD_DACLRCK, 
	AUD_ADCLRCK, 
	AUD_BCLK, 
	AUD_ADCDAT, 
	AUD_DACDAT,
	LEDR
);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	output [9:0] LEDR;
	
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];

	/* Your code goes here */
	parameter BPO = 24;
	parameter OC = 5;
	parameter N = 16;
	parameter TOPSIZE = 1024;
	parameter ND = (N*2)+(OC-1);

	logic signed [24:0] rawInput;
	logic signed [N-1:0] inputSample;
	assign rawInput = readdata_left + readdata_right;
	assign inputSample = rawInput[23:(24-N)];

	logic unsigned [ND-1:0] outBins [0:(BPO*OC)-1];
	DFT #(.BPO(BPO), .OC(OC), .N(N), .TOPSIZE(TOPSIZE), .ND(ND)) TheDFT(.outBins, .inputSample, .sampleReady(read_ready), .doingRead(read), .clk(CLOCK_50), .rst(reset));

	genvar i;
	generate
		for(i = 24; i < 34; i++)
		begin : MakeLEDs
			assign LEDR[33 - i] = (outBins[i][28] | outBins[i][29] | outBins[i][30] | outBins[i][31]);
		end
	endgenerate
	/* End custom code */
	
	clock_generator my_clock_gen(
		CLOCK2_50,
		reset,
		AUD_XCK
	);

	audio_and_video_config cfg(
		CLOCK_50,
		reset,
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		CLOCK_50,
		reset,
		read,	
		write,
		writedata_left, 
		writedata_right,
		AUD_ADCDAT,
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


