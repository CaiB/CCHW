## Generated SDC file "part1.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Intel and sold by Intel or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.0.0 Build 595 04/25/2017 SJ Lite Edition"

## DATE    "Mon Mar 15 20:54:18 2021"

##
## DEVICE  "5CSEMA5F31C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK2_50} -period 37.036 -waveform { 0.000 18.518 } [get_ports {CLOCK2_50}]
create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports { CLOCK_50 }]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {my_clock_gen|DE_Clock_Generator_Audio|auto_generated|generic_pll1~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {my_clock_gen|DE_Clock_Generator_Audio|auto_generated|generic_pll1~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 28 -divide_by 2 -master_clock {CLOCK2_50} [get_pins {my_clock_gen|DE_Clock_Generator_Audio|auto_generated|generic_pll1~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {my_clock_gen|DE_Clock_Generator_Audio|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {my_clock_gen|DE_Clock_Generator_Audio|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 31 -master_clock {my_clock_gen|DE_Clock_Generator_Audio|auto_generated|generic_pll1~FRACTIONAL_PLL|vcoph[0]} [get_pins {my_clock_gen|DE_Clock_Generator_Audio|auto_generated|generic_pll1~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {PLL:PLL12M5|PLL_0002:pll_inst|altera_pll:altera_pll_i|general[0].gpll~FRACTIONAL_PLL_O_VCOPH0} -source [get_pins {PLL12M5|pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50/1 -multiply_by 8 -master_clock {CLOCK_50} [get_pins {PLL12M5|pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {PLL:PLL12M5|PLL_0002:pll_inst|altera_pll:altera_pll_i|outclk_wire[0]} -source [get_pins {PLL12M5|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 32 -master_clock {PLL:PLL12M5|PLL_0002:pll_inst|altera_pll:altera_pll_i|general[0].gpll~FRACTIONAL_PLL_O_VCOPH0} [get_pins {PLL12M5|pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}] -hold 0.060  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -setup 0.170  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -min -clock [get_clocks {CLOCK_50}]  -0.500 [get_ports {KEY[0]}]


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

