# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/LEDModel.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work LEDModel_testbench

# Source the wave file
do wave_LEDModel.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End