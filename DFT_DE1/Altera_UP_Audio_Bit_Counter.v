/* This module counts which bits for serial audio transfers. The module     
 * assume that the data format is I2S, as it is described in the audio        
 * chip's datasheet.                                                          
 * 
 * Inputs:
 *   clk    						- should be connected to a 50 MHz clock
 *   reset  						- resets the module
 *   bit_clk_rising_edge			- does the bit clock signal have a rising edge or not
 *   bit_clk_falling_edge			- does the bit clock signal have a falling edge or not
 *   left_right_clk_rising_edge		- does the left&right clock signal have a rising edge
 *   left_right_clk_falling_edge	- does the left&right clock signal have a falling edge
 *
 * Outputs:
 *   counting      					- which bits to count for serial audio transfers                                                   
 */
module Altera_UP_Audio_Bit_Counter (
	clk,
	reset,
	bit_clk_rising_edge,
	bit_clk_falling_edge,
	left_right_clk_rising_edge,
	left_right_clk_falling_edge,
	counting
);

	parameter BIT_COUNTER_INIT	= 5'h0F;

	input clk;
	input reset;
	input bit_clk_rising_edge;
	input bit_clk_falling_edge;
	input left_right_clk_rising_edge;
	input left_right_clk_falling_edge;
	output reg counting;

	wire reset_bit_counter;
	reg [4:0] bit_counter;

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			bit_counter <= 5'h00;
		else if (reset_bit_counter == 1'b1)
			bit_counter <= BIT_COUNTER_INIT;
		else if ((bit_clk_falling_edge == 1'b1) && (bit_counter != 5'h00))
			bit_counter <= bit_counter - 5'h01;
	end //always @(posedge clk)

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			counting <= 1'b0;
		else if (reset_bit_counter == 1'b1)
			counting <= 1'b1;
		else if ((bit_clk_falling_edge == 1'b1) && (bit_counter == 5'h00))
			counting <= 1'b0;
	end //always @(posedge clk)

	assign reset_bit_counter = left_right_clk_rising_edge | left_right_clk_falling_edge;

endmodule //Altera_UP_Audio_Bit_Counter