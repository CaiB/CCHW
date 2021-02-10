# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/HardLEDValues.sv"
vlog -work work "../src/LEDDriver.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work HardcodedDriver_testbench

# Source the wave file
do Test_HardcodedDriver_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End