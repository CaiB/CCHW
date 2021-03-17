# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/LEDModel.sv"
vlog -work work "../src/Test_LEDModel.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_LEDModel

# Source the wave file
do Test_LEDModel_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End