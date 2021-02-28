/* This module finds clock edges of one clock at the frequency of
 * another clock.
 *
 * Inputs:
 *   clk 			- should be connected to a 50 MHz clock
 *   reset 			- resets the module
 *   test_clk 		- should be connected to a clock to be tested
 *
 * Outputs:
 *   rising_edge 	- the rising edge of the clock signal
 *   falling_edge 	- the falling edge of the clock signal
 *
 */
module Altera_UP_Clock_Edge (
	clk,
	reset,
	test_clk,
	rising_edge,
	falling_edge
);

	input clk;
	input reset;
	input test_clk;
	output rising_edge;
	output falling_edge;

	wire found_edge;
	reg cur_test_clk;
	reg	last_test_clk;

	always @(posedge clk)
		cur_test_clk	<= test_clk;

	always @(posedge clk)
		last_test_clk	<= cur_test_clk;

	assign rising_edge	= found_edge & cur_test_clk;
	assign falling_edge	= found_edge & last_test_clk;
	assign found_edge	= last_test_clk ^ cur_test_clk;

endmodule //Altera_UP_Clock_Edge

