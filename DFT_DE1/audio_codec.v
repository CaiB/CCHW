/* This module reads and writes data to the Audio chip on Altera's DE1
 * Development and Education Board. The audio chip must be in master mode    
 * and the digital format must be left justified.                            
 *
 * Inputs:
 *   clk 				- should be connected to a 50 MHz clock
 *   reset 				- resets the module
 *   read 				- send data from the CODEC (both channels)
 *   write 				- send data to the CODEC (both channels)
 *   writedata_left 	- left channel data to the CODEC
 *   writedata_right 	- right channel data to the CODEC
 *   AUD_ADCDAT 		- should connect to top-level entity I/O of the same name
 *   AUD_BCLK 			- should connect to top-level entity I/O of the same name
 *   AUD_ADCLRCK 		- should connect to top-level entity I/O of the same name
 *   AUD_DACLRCK 		- should connect to top-level entity I/O of the same name
 *
 * Outputs:
 *   read_ready			- CODEC ready for read operation
 *   write_ready 		- CODEC ready for write operation
 *   readdata_left 		- left channel data from the CODEC
 *   readdata_right 	- right channel data from the CODEC
 *   AUD_DACDAT 		- should connect to top-level entity I/O of the same name
 *
 */
module audio_codec (
	clk,
	reset,
	read,	
	write,
	writedata_left, 
	writedata_right,
	AUD_ADCDAT,
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	read_ready, 
	write_ready,
	readdata_left, 
	readdata_right,
	AUD_DACDAT
);

	parameter AUDIO_DATA_WIDTH	= 24;
	parameter BIT_COUNTER_INIT	= 5'd23;

	input clk;
	input reset;
	input read;
	input write;
	input [AUDIO_DATA_WIDTH-1:0] writedata_left;
	input [AUDIO_DATA_WIDTH-1:0] writedata_right;
	input AUD_ADCDAT;
	input AUD_BCLK;
	input AUD_ADCLRCK;
	input AUD_DACLRCK;
	output read_ready, write_ready;
	output [AUDIO_DATA_WIDTH-1:0] readdata_left;
	output [AUDIO_DATA_WIDTH-1:0] readdata_right;
	output AUD_DACDAT;

	wire bclk_rising_edge;
	wire bclk_falling_edge;
	wire adc_lrclk_rising_edge;
	wire adc_lrclk_falling_edge;
	wire [AUDIO_DATA_WIDTH:1] new_left_channel_audio;
	wire [AUDIO_DATA_WIDTH:1] new_right_channel_audio;
	wire [7:0] left_channel_read_available;
	wire [7:0] right_channel_read_available;
	wire dac_lrclk_rising_edge;
	wire dac_lrclk_falling_edge;
	wire [7:0] left_channel_write_space;
	wire [7:0] right_channel_write_space;
	reg	done_adc_channel_sync;
	reg	done_dac_channel_sync;

	always @ (posedge clk)
	begin
		if (reset == 1'b1)
			done_adc_channel_sync <= 1'b0;
		else if (adc_lrclk_rising_edge == 1'b1)
			done_adc_channel_sync <= 1'b1;
	end //always @ (posedge clk)

	always @ (posedge clk)
	begin
		if (reset == 1'b1)
			done_dac_channel_sync <= 1'b0;
		else if (dac_lrclk_falling_edge == 1'b1)
			done_dac_channel_sync <= 1'b1;
	end //always @ (posedge clk)

	assign read_ready = (left_channel_read_available != 8'd0) & (right_channel_read_available != 8'd0);
	assign write_ready = (left_channel_write_space != 8'd0) & (right_channel_write_space != 8'd0);
	assign readdata_left = new_left_channel_audio;
	assign readdata_right = new_right_channel_audio;

	Altera_UP_Clock_Edge Bit_Clock_Edges (
		.clk			(clk),
		.reset			(reset),
		.test_clk		(AUD_BCLK),
		.rising_edge	(bclk_rising_edge),
		.falling_edge	(bclk_falling_edge)
	);

	Altera_UP_Clock_Edge ADC_Left_Right_Clock_Edges (
		.clk			(clk),
		.reset			(reset),
		.test_clk		(AUD_ADCLRCK),
		.rising_edge	(adc_lrclk_rising_edge),
		.falling_edge	(adc_lrclk_falling_edge)
	);

	Altera_UP_Clock_Edge DAC_Left_Right_Clock_Edges (
		.clk			(clk),
		.reset			(reset),
		.test_clk		(AUD_DACLRCK),
		.rising_edge	(dac_lrclk_rising_edge),
		.falling_edge	(dac_lrclk_falling_edge)
	);

	Altera_UP_Audio_In_Deserializer Audio_In_Deserializer (
		.clk							(clk),
		.reset							(reset),
		.bit_clk_rising_edge			(bclk_rising_edge),
		.bit_clk_falling_edge			(bclk_falling_edge),
		.left_right_clk_rising_edge		(adc_lrclk_rising_edge),
		.left_right_clk_falling_edge	(adc_lrclk_falling_edge),
		.done_channel_sync				(done_adc_channel_sync),
		.serial_audio_in_data			(AUD_ADCDAT),
		.read_left_audio_data_en		(read & (left_channel_read_available != 8'd0)),
		.read_right_audio_data_en		(read & (right_channel_read_available != 8'd0)),
		.left_audio_fifo_read_space		(left_channel_read_available),
		.right_audio_fifo_read_space	(right_channel_read_available),
		.left_channel_data				(new_left_channel_audio),
		.right_channel_data				(new_right_channel_audio)
	);
	defparam
		Audio_In_Deserializer.AUDIO_DATA_WIDTH = AUDIO_DATA_WIDTH,
		Audio_In_Deserializer.BIT_COUNTER_INIT = BIT_COUNTER_INIT;


	Altera_UP_Audio_Out_Serializer Audio_Out_Serializer (
		.clk							(clk),
		.reset							(reset),
		.bit_clk_rising_edge			(bclk_rising_edge),
		.bit_clk_falling_edge			(bclk_falling_edge),
		.left_right_clk_rising_edge		(done_dac_channel_sync & dac_lrclk_rising_edge),
		.left_right_clk_falling_edge	(done_dac_channel_sync & dac_lrclk_falling_edge),
		.left_channel_data				(writedata_left),
		.left_channel_data_en			(write & (left_channel_write_space != 8'd0)),
		.right_channel_data				(writedata_right),
		.right_channel_data_en			(write & (right_channel_write_space != 8'd0)),
		.left_channel_fifo_write_space	(left_channel_write_space),
		.right_channel_fifo_write_space	(right_channel_write_space),
		.serial_audio_out_data			(AUD_DACDAT)
	);
	defparam
		Audio_Out_Serializer.AUDIO_DATA_WIDTH = AUDIO_DATA_WIDTH;

endmodule //audio_codec

