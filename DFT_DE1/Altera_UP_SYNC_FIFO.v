/* This module is a FIFO with same clock for both reads and writes. 
 *   
 * Inputs:
 *   clk 			- should be connected to a 50 MHz clock
 *   reset 			- resets the module
 *   write_en 		- enable the write to FIFO
 *   write_data 	- data to be written to FIFO
 *   read_en 		- enable the read from FIFO
 *
 * Outputs:
 *   fifo_is_empty 	- if the FIFO is empty or not
 *   fifo_is_full 	- if the FIFO is full or not
 *   words_used 	- space used in FIFO
 *   read_data 		- data to be read from the FIFO
 */
module Altera_UP_SYNC_FIFO (
	clk,
	reset,
	write_en,
	write_data,
	read_en,
	fifo_is_empty,
	fifo_is_full,
	words_used,
	read_data
);

	parameter DATA_WIDTH = 32;
	parameter DATA_DEPTH = 128;
	parameter ADDR_WIDTH = 7;

	input clk;
	input reset;
	input write_en;
	input [DATA_WIDTH:1] write_data;
	input read_en;
	output fifo_is_empty;
	output fifo_is_full;
	output [ADDR_WIDTH:1] words_used;
	output [DATA_WIDTH:1] read_data;

	scfifo	Sync_FIFO (
		.clock			(clk),
		.sclr			(reset),
		.data			(write_data),
		.wrreq			(write_en),
		.rdreq			(read_en),
		.empty			(fifo_is_empty),
		.full			(fifo_is_full),
		.usedw			(words_used),
		.q				(read_data),
		.aclr			(),
		.almost_empty	(),
		.almost_full	()
	);
	defparam
		Sync_FIFO.add_ram_output_register	= "OFF",
		Sync_FIFO.intended_device_family	= "Cyclone II",
		Sync_FIFO.lpm_numwords				= DATA_DEPTH,
		Sync_FIFO.lpm_showahead				= "ON",
		Sync_FIFO.lpm_type					= "scfifo",
		Sync_FIFO.lpm_width					= DATA_WIDTH,
		Sync_FIFO.lpm_widthu				= ADDR_WIDTH,
		Sync_FIFO.overflow_checking			= "OFF",
		Sync_FIFO.underflow_checking		= "OFF",
		Sync_FIFO.use_eab					= "ON";

endmodule //Altera_UP_SYNC_FIFO

