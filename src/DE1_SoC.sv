// Top-level module that defines the I/Os for the DE-1 SoC board   
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	output logic [ 6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [ 9:0]  LEDR;
	inout  logic [35:0]  GPIO_0;
	input  logic [ 3:0]  KEY;
	input  logic [ 9:0]  SW;
	input  logic 		   CLOCK50;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
endmodule