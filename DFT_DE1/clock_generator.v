
/*This module generates the clocks needed for the I/O devices on
 * Altera's DE1 and DE2 Boards.                              
 * 
 * Inputs:
 *   CLOCK2_50 	- should be connected to a 50 MHz clock
 *   reset		- resets the module
 *
 * Outputs:
 *   AUD_XCK	- should connect to top-level entity I/O of the same name
 *                                              
 */

module clock_generator (
	CLOCK2_50,
	reset,
	AUD_XCK
);

	parameter AUD_CLK_MULT = 14;
	parameter AUD_CLK_DIV = 31;

	input CLOCK2_50;
	input reset;
	output AUD_XCK;

	wire audio_clk_locked;

	altpll DE_Clock_Generator_Audio (
		.inclk			({1'b0, CLOCK2_50}),
		.clk			(AUD_XCK),
		.locked			(audio_clk_locked),
		.activeclock	(),
		.areset			(reset),
		.clkbad			(),
		.clkena			({6{1'b1}}),
		.clkloss		(),
		.clkswitch		(1'b0),
		.enable0		(),
		.enable1		(),
		.extclk			(),
		.extclkena		({4{1'b1}}),
		.fbin			(1'b1),
		.pfdena			(1'b1),
		.pllena			(1'b1),
		.scanaclr		(1'b0),
		.scanclk		(1'b0),
		.scandata		(1'b0),
		.scandataout	(),
		.scandone		(),
		.scanread		(1'b0),
		.scanwrite		(1'b0),
		.sclkout0		(),
		.sclkout1		()
	);
	defparam
		DE_Clock_Generator_Audio.clk0_divide_by				= AUD_CLK_DIV,
		DE_Clock_Generator_Audio.clk0_duty_cycle			= 50,
		DE_Clock_Generator_Audio.clk0_multiply_by			= AUD_CLK_MULT,
		DE_Clock_Generator_Audio.clk0_phase_shift			= "0",
		DE_Clock_Generator_Audio.compensate_clock			= "CLK0",
		DE_Clock_Generator_Audio.gate_lock_signal			= "NO",
		DE_Clock_Generator_Audio.inclk0_input_frequency		= 37037,
		DE_Clock_Generator_Audio.intended_device_family		= "Cyclone II",
		DE_Clock_Generator_Audio.invalid_lock_multiplier	= 5,
		DE_Clock_Generator_Audio.lpm_type					= "altpll",
		DE_Clock_Generator_Audio.operation_mode				= "NORMAL",
		DE_Clock_Generator_Audio.pll_type					= "FAST",
		DE_Clock_Generator_Audio.port_activeclock			= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_areset				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkbad0				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkbad1				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkloss				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkswitch				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_fbin					= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_inclk0				= "PORT_USED",
		DE_Clock_Generator_Audio.port_inclk1				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_locked				= "PORT_USED",
		DE_Clock_Generator_Audio.port_pfdena				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_pllena				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_scanaclr				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_scanclk				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_scandata				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_scandataout			= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_scandone				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_scanread				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_scanwrite				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clk0					= "PORT_USED",
		DE_Clock_Generator_Audio.port_clk1					= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clk2					= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clk3					= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clk4					= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clk5					= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkena0				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkena1				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkena2				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkena3				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkena4				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_clkena5				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_enable0				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_enable1				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclk0				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclk1				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclk2				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclk3				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclkena0			= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclkena1			= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclkena2			= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_extclkena3			= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_sclkout0				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.port_sclkout1				= "PORT_UNUSED",
		DE_Clock_Generator_Audio.valid_lock_multiplier		= 1;

endmodule //clock_generator

