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
	/*

	localparam LEDS = 50;		// number of leds being driver
	localparam COMPLEXITY = 3;	// see HardLEDValues.sv header comment for explanation
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
        .FREQ(781_250)
    ) u_LEDDriver (
        .dOut    (GPIO_0[18]),	// using 18 because I think it already has resistance in series
        .clkOut  (GPIO_0[19]),	// using 19 because I think it already has resistance in series
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
	*/
	// --------------------------------------------------------------------------------------------
	// 							LEDDriver and Linear Visulizer Test

	parameter W = 6;        	// max whole value 63
	parameter D = 10;       	// decimal precision to ~.001
	parameter LEDS  = 50;   	// number of LEDs being driven
	parameter BIN_QTY = 12;	
	parameter FREQ_DIV = 8;			// how much slower driver output frequency is to the sys clock

	integer i;

	logic rst;
	logic dOut, clkOut;
    logic [BIN_QTY - 1 : 0][23 : 0] rgb;
    logic [BIN_QTY - 1 : 0][$clog2(LEDS) - 1 : 0] LEDCounts;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] noteAmplitudes;
    logic [BIN_QTY - 1 : 0][W + D - 1 : 0] notePositions;

    logic ld_done, lv_dv;
    logic lv_start;

	// PLL STUFF
	logic locked;
	logic clk_12M5;

	assign rst = ~KEY[0];
	assign GPIO_0[18] = dOut;
	assign GPIO_0[19] = clkOut;
	assign LEDR[0] = locked;
	assign LEDR[1] = lv_dv;
	assign LEDR[2] = ld_done;
	assign LEDR[9] = rst;
	assign lv_start = '1;

	
	logic [W + D - 1 : 0] testAmplitudes [BIN_QTY - 1 : 0];
    logic [W + D - 1 : 0] testPositions [BIN_QTY - 1 : 0];

    initial begin
        $readmemb("../other/testNotePositions.mem", testPositions);
        $readmemb("../other/testNoteAmplitudes.mem", testAmplitudes);
    end

	always_comb begin
		noteAmplitudes = '0;
		notePositions = '0;

		for (i = 0; i < BIN_QTY; i++) begin
            noteAmplitudes[i] = testAmplitudes[i];
            notePositions[i] = testPositions[i];
		end
	end

	PLL pll (
		.refclk		(CLOCK50),  //  refclk.clk
		.rst		(rst	),  //   reset.reset
		.outclk_0	(clk_12M5), // outclk0.clk
		.locked		(locked	)   //  locked.export
	);

	LEDDriver2 #(
		.FREQ_DIV(4)
		) ld_u (
		.dOut    (dOut      ),
		.clkOut  (clkOut    ),
		.done    (ld_done   ),
		.rgb     (rgb       ),
		.LEDCounts(LEDCounts),
		.start   (lv_dv     ),
		.clk     (clk_12M5  ),
		.rst     (rst || !locked)
	);


    LinearVisualizer lv_u (
        .rgb            (rgb            ),
        .LEDCounts      (LEDCounts      ),
        .data_v         (lv_dv          ),
        .noteAmplitudes (noteAmplitudes ),
        .notePositions  (notePositions  ),
        .start          (lv_start       ),
        .clk            (clk_12M5       ),
        .rst            (rst || !locked )
    );
	
endmodule