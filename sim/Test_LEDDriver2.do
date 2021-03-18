# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/Common.sv"
vlog -work work "../src/LEDModel.sv"
vlog -work work "../src/LEDDriver2.sv"
vlog -work work "../src/Test_LEDDriver2.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_LEDDriver2

# Source the wave file
do Test_LEDDriver2_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End