// Top-level module that defines the I/Os for the DE-1 SoC board   
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, GPIO_0, CLOCK50);
	output logic [ 6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [ 9:0]  LEDR;
	inout  logic [35:0]  GPIO_0;
	input  logic [ 3:0]  KEY;
	input  logic [ 9:0]  SW;
	input  logic 		 CLOCK50;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;


	// --------------------------------------------------------------------------------------------
	//									LED Driver Test
	// set LEDS to the number of WS2801 LEDs in series in your LED strip
	// set complexity to 0, 1 or 2 based on the behavior you want to see described in HardLedValues.sv
	// feel free to modify the reset assignment to what you would like instead


	localparam LEDS = 50;		// number of leds being driver
	localparam COMPLEXITY = 2;	// see HardLEDValues.sv header comment for explanation
	assign rst = ~KEY[0];

	logic start, done;
	logic [(24*LEDS)-1:0] led_rgb;
	logic [5:0] clk_divider;
	logic rst, clk;
	

	always_ff @(posedge CLOCK50) begin
		clk_divider <= rst ? '0 : clk_divider + 1'b1;
	end

	assign clk = clk_divider[5]; 

	LEDDriver #(
        .LEDS(LEDS), 
        .FREQ(781250)
    ) u_LEDDriver (
        .dOut    (GPIO_0[18]),	// using 18 because I think it already has resistance in series
        .clkOut  (GPIO_0[19]),	// using 18 because I think it already has resistance in series
        .done    (done   ),
        .led_rgb (led_rgb),
        .start   (start  ),
        .clk     (clk    ),
        .rst     (rst    )
    );

    HardLEDValues #(
        .LEDS(LEDS), 
        .COMPLEXITY(COMPLEXITY)
    ) u_HardLEDValues (
        .led_rgb(led_rgb), 
        .start  (start  ), 
        .done   (done   ), 
        .rst    (rst    )
    );

	// --------------------------------------------------------------------------------------------
	
endmodule