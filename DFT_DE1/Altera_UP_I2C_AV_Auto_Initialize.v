/* This module loads data into the Audio and Video chips' control 
 * registers after system reset.                      
 * 
 * Inputs:
 *   clk 				- should be connected to a 50 MHz clock
 *   reset 				- resets the module
 *   clear_error 		- signal to clear the error message
 *   ack 				- ackowledgement signal
 *   transfer_complete 	- is the trasfer completed
 *
 * Outputs:
 *   data_out 			- data sent to DE1 audio
 *   transfer_data 		- data to be transfered
 *   send_start_bit 	- bit to start recieving data
 *   send_stop_bit 		- bit to stop recieving data
 *   auto_init_complete - is the auto initialization complete
 *   auto_init_erro 	- error that happened during auto initialization
 */

module Altera_UP_I2C_AV_Auto_Initialize (
	clk,
	reset,
	clear_error,
	ack,
	transfer_complete,
	data_out,
	transfer_data,
	send_start_bit,
	send_stop_bit,
	auto_init_complete,
	auto_init_error
);

	parameter MIN_ROM_ADDRESS	= 6'h00;
	parameter MAX_ROM_ADDRESS	= 6'h32;
	parameter AUD_LINE_IN_LC	= 9'h01A;
	parameter AUD_LINE_IN_RC	= 9'h01A;
	parameter AUD_LINE_OUT_LC	= 9'h07B;
	parameter AUD_LINE_OUT_RC	= 9'h07B;
	parameter AUD_ADC_PATH		= 9'h0F8;
	parameter AUD_DAC_PATH		= 9'h006;
	parameter AUD_POWER			= 9'h000;
	parameter AUD_DATA_FORMAT	= 9'h001;
	parameter AUD_SAMPLE_CTRL	= 9'h002;
	parameter AUD_SET_ACTIVE	= 9'h001;

	input clk;
	input reset;
	input clear_error;
	input ack;
	input transfer_complete;
	output reg [7:0] data_out;
	output reg transfer_data;
	output reg send_start_bit;
	output reg send_stop_bit;
	output auto_init_complete;
	output reg auto_init_error;

	// States
	localparam	AUTO_STATE_0_CHECK_STATUS		= 3'h0,
				AUTO_STATE_1_SEND_START_BIT		= 3'h1,
				AUTO_STATE_2_TRANSFER_BYTE_1	= 3'h2,
				AUTO_STATE_3_TRANSFER_BYTE_2	= 3'h3,
				AUTO_STATE_4_WAIT				= 3'h4,
				AUTO_STATE_5_SEND_STOP_BIT		= 3'h5,
				AUTO_STATE_6_INCREASE_COUNTER	= 3'h6,
				AUTO_STATE_7_DONE				= 3'h7;

	wire change_state;
	wire finished_auto_init;
	reg [5:0] rom_address_counter;
	reg [25:0] rom_data;
	reg [2:0] ns_i2c_auto_init;
	reg [2:0] s_i2c_auto_init;

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			s_i2c_auto_init <= AUTO_STATE_0_CHECK_STATUS;
		else
			s_i2c_auto_init <= ns_i2c_auto_init;
	end //always @(posedge clk)

	always @(*)
	begin
		// Defaults
		ns_i2c_auto_init = AUTO_STATE_0_CHECK_STATUS;

		case (s_i2c_auto_init)
		AUTO_STATE_0_CHECK_STATUS:
			begin
				if (finished_auto_init == 1'b1)
					ns_i2c_auto_init = AUTO_STATE_7_DONE;
				else if (rom_data[25] == 1'b1)
					ns_i2c_auto_init = AUTO_STATE_1_SEND_START_BIT;
				else
					ns_i2c_auto_init = AUTO_STATE_3_TRANSFER_BYTE_2;
			end //AUTO_STATE_0_CHECK_STATUS
		AUTO_STATE_1_SEND_START_BIT:
			begin
				if (change_state == 1'b1)
					ns_i2c_auto_init = AUTO_STATE_2_TRANSFER_BYTE_1;
				else
					ns_i2c_auto_init = AUTO_STATE_1_SEND_START_BIT;
			end //AUTO_STATE_1_SEND_START_BIT
		AUTO_STATE_2_TRANSFER_BYTE_1:
			begin
				if (change_state == 1'b1)
					ns_i2c_auto_init = AUTO_STATE_3_TRANSFER_BYTE_2;
				else
					ns_i2c_auto_init = AUTO_STATE_2_TRANSFER_BYTE_1;
			end //AUTO_STATE_2_TRANSFER_BYTE_1
		AUTO_STATE_3_TRANSFER_BYTE_2:
			begin
				if ((change_state == 1'b1) && (rom_data[24] == 1'b1))
					ns_i2c_auto_init = AUTO_STATE_4_WAIT;
				else if (change_state == 1'b1)
					ns_i2c_auto_init = AUTO_STATE_6_INCREASE_COUNTER;
				else
					ns_i2c_auto_init = AUTO_STATE_3_TRANSFER_BYTE_2;
			end //AUTO_STATE_3_TRANSFER_BYTE_2
		AUTO_STATE_4_WAIT:
			begin
				if (transfer_complete == 1'b0)
					ns_i2c_auto_init = AUTO_STATE_5_SEND_STOP_BIT;
				else
					ns_i2c_auto_init = AUTO_STATE_4_WAIT;
			end //AUTO_STATE_4_WAIT
		AUTO_STATE_5_SEND_STOP_BIT:
			begin
				if (transfer_complete == 1'b1)
					ns_i2c_auto_init = AUTO_STATE_6_INCREASE_COUNTER;
				else
					ns_i2c_auto_init = AUTO_STATE_5_SEND_STOP_BIT;
			end //AUTO_STATE_5_SEND_STOP_BIT
		AUTO_STATE_6_INCREASE_COUNTER:
			begin
				ns_i2c_auto_init = AUTO_STATE_0_CHECK_STATUS;
			end //AUTO_STATE_6_INCREASE_COUNTER
		AUTO_STATE_7_DONE:
			begin
				ns_i2c_auto_init = AUTO_STATE_7_DONE;
			end //AUTO_STATE_7_DONE
		default:
			begin
				ns_i2c_auto_init = AUTO_STATE_0_CHECK_STATUS;
			end //default
		endcase //case (s_i2c_auto_init)
	end //always @(*)

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			data_out <= 8'h00;
		else if (s_i2c_auto_init == AUTO_STATE_1_SEND_START_BIT)
			data_out <= rom_data[23:16];
		else if (s_i2c_auto_init == AUTO_STATE_0_CHECK_STATUS)
			data_out <= rom_data[15: 8];
		else if (s_i2c_auto_init == AUTO_STATE_2_TRANSFER_BYTE_1)
			data_out <= rom_data[15: 8];
		else if (s_i2c_auto_init == AUTO_STATE_3_TRANSFER_BYTE_2)
			data_out <= rom_data[ 7: 0];
	end //always @(posedge clk)

	always @(posedge clk)
	begin
		if (reset == 1'b1) 
			transfer_data <= 1'b0;
		else if (transfer_complete == 1'b1)
			transfer_data <= 1'b0;
		else if (s_i2c_auto_init == AUTO_STATE_1_SEND_START_BIT)
			transfer_data <= 1'b1;
		else if (s_i2c_auto_init == AUTO_STATE_2_TRANSFER_BYTE_1)
			transfer_data <= 1'b1;
		else if (s_i2c_auto_init == AUTO_STATE_3_TRANSFER_BYTE_2)
			transfer_data <= 1'b1;
	end //always @(posedge clk)

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			send_start_bit <= 1'b0;
		else if (transfer_complete == 1'b1)
			send_start_bit <= 1'b0;
		else if (s_i2c_auto_init == AUTO_STATE_1_SEND_START_BIT)
			send_start_bit <= 1'b1;
	end //always @(posedge clk)

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			send_stop_bit <= 1'b0;
		else if (transfer_complete == 1'b1)
			send_stop_bit <= 1'b0;
		else if (s_i2c_auto_init == AUTO_STATE_5_SEND_STOP_BIT)
			send_stop_bit <= 1'b1;
	end //always @(posedge clk)

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			auto_init_error <= 1'b0;
		else if (clear_error == 1'b1)
			auto_init_error <= 1'b0;
		else if ((s_i2c_auto_init == AUTO_STATE_6_INCREASE_COUNTER) & ack)
			auto_init_error <= 1'b1;
	end //always @(posedge clk)

	always @(posedge clk)
	begin
		if (reset == 1'b1)
			rom_address_counter <= MIN_ROM_ADDRESS;
		else if (s_i2c_auto_init == AUTO_STATE_6_INCREASE_COUNTER)
			rom_address_counter <= rom_address_counter + 6'h01;
	end //always @(posedge clk)

	assign auto_init_complete = (s_i2c_auto_init == AUTO_STATE_7_DONE);
	assign change_state	= transfer_complete & transfer_data;
	assign finished_auto_init = (rom_address_counter == MAX_ROM_ADDRESS);

	always @(*)
	begin
		case (rom_address_counter)
		//	Audio Config Data
		0		: rom_data <= {10'h334, 7'h0, AUD_LINE_IN_LC};
		1		: rom_data <= {10'h334, 7'h1, AUD_LINE_IN_RC};
		2		: rom_data <= {10'h334, 7'h2, AUD_LINE_OUT_LC};
		3		: rom_data <= {10'h334, 7'h3, AUD_LINE_OUT_RC};
		4		: rom_data <= {10'h334, 7'h4, AUD_ADC_PATH};
		5		: rom_data <= {10'h334, 7'h5, AUD_DAC_PATH};
		6		: rom_data <= {10'h334, 7'h6, AUD_POWER};
		7		: rom_data <= {10'h334, 7'h7, AUD_DATA_FORMAT};
		8		: rom_data <= {10'h334, 7'h8, AUD_SAMPLE_CTRL};
		9		: rom_data <= {10'h334, 7'h9, AUD_SET_ACTIVE};
		//	Video Config Daa
	 	10		: rom_data <= 26'h3401500;
		11		: rom_data <= 26'h3401741;
		12		: rom_data <= 26'h3403a16;
		13		: rom_data <= 26'h3405004;
		14		: rom_data <= 26'h340c305;
		15		: rom_data <= 26'h340c480;
		16		: rom_data <= 26'h3400e80;
		17		: rom_data <= 26'h3405020;
		18		: rom_data <= 26'h3405218;
		19		: rom_data <= 26'h34058ed;
		20		: rom_data <= 26'h34077c5;
		21		: rom_data <= 26'h3407c93;
		22		: rom_data <= 26'h3407d00;
		23		: rom_data <= 26'h340d048;
		24		: rom_data <= 26'h340d5a0;
		25		: rom_data <= 26'h340d7ea;
		26		: rom_data <= 26'h340e43e;
		27		: rom_data <= 26'h340ea0f;
		28		: rom_data <= 26'h3403112;
		29		: rom_data <= 26'h3403281;
		30		: rom_data <= 26'h3403384;
		31		: rom_data <= 26'h34037A0;
		32		: rom_data <= 26'h340e580;
		33		: rom_data <= 26'h340e603;
		34		: rom_data <= 26'h340e785;
		35		: rom_data <= 26'h3405000;
		36		: rom_data <= 26'h3405100;
		37		: rom_data <= 26'h3400070;
		38		: rom_data <= 26'h3401010;
		39		: rom_data <= 26'h3400482;
		40		: rom_data <= 26'h3400860;
		41		: rom_data <= 26'h3400a18;
		42		: rom_data <= 26'h3401100;
		43		: rom_data <= 26'h3402b00;
		44		: rom_data <= 26'h3402c8c;
		45		: rom_data <= 26'h3402df2;
		46		: rom_data <= 26'h3402eee;
		47		: rom_data <= 26'h3402ff4;
		48		: rom_data <= 26'h34030d2;
		49		: rom_data <= 26'h3400e05;
		default	: rom_data <= 26'h1000000;
		endcase //case (rom_address_counter)
	end //always @(*)

endmodule //Altera_UP_I2C_AV_Auto_Initialize

