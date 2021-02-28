/* Noise-generating circuit for use in Lab 5, in case you have a noise-cancelling microphone.
 *
 * Inputs:
 *   clk    - should be connected to a 50 MHz clock
 *   enable - driven high when the Audio CODEC module can both produce and accept a new sample
 *
 * Outputs:
 *   Q      - noise value (signed) to add to sound sample
 */
module noise_generator (clk, enable, Q);

	input  logic clk, enable;
	output logic [23:0] Q;

	logic [2:0] counter;

	always_ff @(posedge clk)
		if (enable)
			counter = counter + 1’b1;
			
	assign Q = {{10{counter[2]}}, counter, 11’d0};
	
endmodule //noise_generator
