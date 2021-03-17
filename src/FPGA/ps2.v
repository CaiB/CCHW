//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE2_115_PS2 Mouse Controller 
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author                    :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN,HdHuang        :| 05/16/10  :| Initial Revision
//   V2.0 :| Kyle Gagner               :| 12/6/15   :| Modified for EE 271 students @ UW
//   V2.1 :| Kyle Gagner               :| 1/17/16   :| Made start & reset active high
// --------------------------------------------------------------------
module ps2
	#(
		parameter WIDTH = 10,
		parameter HEIGHT = 10,
		parameter BIN = 10,
		parameter HYSTERESIS = 3
	)
	(
		start,         // transmit instrucions to device
		reset,         // FSM reset signal
		CLOCK_50,      //clock source
		PS2_CLK,       //ps2_clock signal inout
		PS2_DAT,       //ps2_data  signal inout
		button_left,   //left button press display
		button_right,  //right button press display
		button_middle, //middle button press display
		bin_x,         //binned X position with hysteresis
		bin_y          //binned Y position with hysteresis
	);

//=======================================================
//  PARAMETERS
//=======================================================
parameter UPPER_BITS = $clog2(WIDTH>HEIGHT?WIDTH:HEIGHT);
parameter LOWER_BITS = $clog2(BIN+HYSTERESIS+256)+1;
parameter THRESHOLD = BIN+HYSTERESIS;

//=======================================================
//  PORT declarations
//=======================================================

input start;
input reset;
input CLOCK_50;

inout PS2_CLK;
inout PS2_DAT;

output reg button_left;
output reg button_right;
output reg button_middle;
output reg [UPPER_BITS-1:0] bin_x;
output reg [UPPER_BITS-1:0] bin_y;

//instruction define, users can charge the instruction byte here for other purpose according to ps/2 mouse datasheet.
//the MSB is of parity check bit, that's when there are odd number of 1's with data bits, it's value is '0',otherwise it's '1' instead.

parameter enable_byte =9'b011110100;


//=======================================================
//  REG/WIRE declarations
//=======================================================
reg [1:0] cur_state,nex_state;
reg ce,de;
reg [3:0] byte_cnt,delay;
reg [5:0] ct;
reg [7:0] cnt;
reg [8:0] clk_div;
reg [9:0] dout_reg;
reg [32:0] shift_reg;
reg       leflatch,riglatch,midlatch;
reg       ps2_clk_in,ps2_clk_syn1,ps2_dat_in,ps2_dat_syn1;
wire      clk,ps2_dat_syn0,ps2_clk_syn0,ps2_dat_out,ps2_clk_out,flag;
reg [LOWER_BITS-1:0] x_latch;
reg [LOWER_BITS-1:0] y_latch;
reg [UPPER_BITS-1:0] oX_BIN;
reg [UPPER_BITS-1:0] oY_BIN;

//=======================================================
//  PARAMETER declarations
//=======================================================
//state define
parameter listen =2'b00,
          pullclk=2'b01,
          pulldat=2'b10,
          trans  =2'b11;
          
//=======================================================
//  Structural coding
//=======================================================          
//clk division, derive a 97.65625KHz clock from the 50MHz source;

always@(posedge CLOCK_50)
	begin
		clk_div <= clk_div+1;
	end
	
assign clk = clk_div[8];
//tristate output control for PS2_DAT and PS2_CLK;
assign PS2_CLK = ce?ps2_clk_out:1'bZ;
assign PS2_DAT = de?ps2_dat_out:1'bZ;
assign ps2_clk_out = 1'b0;
assign ps2_dat_out = dout_reg[0];
assign ps2_clk_syn0 = ce?1'b1:PS2_CLK;
assign ps2_dat_syn0 = de?1'b1:PS2_DAT;
// deal with any issues which may be due to moving between clock domains
reg [9:0] starttimer;
always @(posedge CLOCK_50)
begin
	if(start) starttimer <= 1'b1;
	else if(starttimer) starttimer <= starttimer + 1'b1;
	button_left = leflatch;
	button_right = riglatch;
	button_middle = midlatch;
	bin_x = oX_BIN;
	bin_y = oY_BIN;
end
//multi-clock region simple synchronization
always@(posedge clk)
	begin
		ps2_clk_syn1 <= ps2_clk_syn0;
		ps2_clk_in   <= ps2_clk_syn1;
		ps2_dat_syn1 <= ps2_dat_syn0;
		ps2_dat_in   <= ps2_dat_syn1;
	end
//FSM shift
always@(*)
begin
   case(cur_state)
     listen  :begin
              if (starttimer && (cnt == 8'b11111111))
                  nex_state = pullclk;
              else
                  nex_state = listen;
                         ce = 1'b0;
                         de = 1'b0;
              end
     pullclk :begin
              if (delay == 4'b1100)
                  nex_state = pulldat;
              else
                  nex_state = pullclk;
                         ce = 1'b1;
                         de = 1'b0;
              end
     pulldat :begin
                  nex_state = trans;
                         ce = 1'b1;
                         de = 1'b1;
              end
     trans   :begin
              if  (byte_cnt == 4'b1010)
                  nex_state = listen;
              else    
                  nex_state = trans;
                         ce = 1'b0;
                         de = 1'b1;
              end
     default :    nex_state = listen;
   endcase
end
//idle counter
always@(posedge clk)
begin
  if ({ps2_clk_in,ps2_dat_in} == 2'b11)
	begin
		cnt <= cnt+1;
    end
  else begin
		cnt <= 8'd0;
       end
end
//periodically reset ct; ct counts the received data length;
assign flag = (cnt == 8'hff)?1:0;
always@(posedge ps2_clk_in,posedge flag)
begin
  if (flag)
     ct <= 6'b000000;
  else
     ct <= ct+1;
end
//latch data from shift_reg;outputs is of 2's complement;
//Please treat the cnt value here with caution, otherwise wrong data will be latched.
always@(posedge clk, posedge reset)
begin
   if(reset)
   begin
      leflatch <= 1'b0;
      riglatch <= 1'b0;
      midlatch <= 1'b0;
      x_latch  <= 0;
      y_latch  <= 0;
      oX_BIN <= 0;
      oY_BIN <= 0;
   end
   else if (cnt == 8'b00011110 && (ct[5] == 1'b1 || ct[4] == 1'b1))
   begin
      leflatch <= shift_reg[1];
      riglatch <= shift_reg[2];
      midlatch <= shift_reg[3];
      x_latch  <= x_latch+{{(LOWER_BITS-8){shift_reg[19]}},shift_reg[19 : 12]};
      y_latch  <= y_latch+{{(LOWER_BITS-8){shift_reg[30]}},shift_reg[30 : 23]};
   end
	else
	begin
		if($signed(x_latch) >= THRESHOLD)
		begin
			x_latch <= x_latch - BIN;
			if(oX_BIN != HEIGHT-1)
			begin
				oX_BIN <= oX_BIN + 1'b1;
			end
		end
		else if($signed(x_latch) <= -THRESHOLD)
		begin
			x_latch <= x_latch + BIN;
			if(oX_BIN != 0)
			begin
				oX_BIN <= oX_BIN - 1'b1;
			end
		end
		
		if($signed(y_latch) >= THRESHOLD)
		begin
			y_latch <= y_latch - BIN;
			if(oY_BIN != HEIGHT-1)
			begin
				oY_BIN <= oY_BIN + 1'b1;
			end
		end
		else if($signed(y_latch) <= -THRESHOLD)
		begin
			y_latch <= y_latch + BIN;
			if(oY_BIN != 0)
			begin
				oY_BIN <= oY_BIN - 1'b1;
			end
		end
		
	end
end

//pull ps2_clk low for 100us before transmit starts;
always@(posedge clk)
begin
  if (cur_state == pullclk)
     delay <= delay+1;
  else
     delay <= 4'b0000;
end
//transmit data to ps2 device;eg. 0xF4
always@(negedge ps2_clk_in)
begin
  if (cur_state == trans)
     dout_reg <= {1'b0,dout_reg[9:1]};
  else
     dout_reg <= {enable_byte,1'b0};
end
//transmit byte length counter
always@(negedge ps2_clk_in)
begin
  if (cur_state == trans)
     byte_cnt <= byte_cnt+1;
  else
     byte_cnt <= 4'b0000;
end
//receive data from ps2 device;
always@(negedge ps2_clk_in)
begin
  if (cur_state == listen)
     shift_reg <= {ps2_dat_in,shift_reg[32:1]};
end
//FSM movement
always@(posedge clk,posedge reset)
begin
  if (reset)
     cur_state <= listen;
  else
     cur_state <= nex_state;
end
endmodule


     


     


