# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/LEDModel.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work LEDStripModel_testbench

# Source the wave file
do Test_LEDStripModel_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End