# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/DFT2.sv"
vlog -work work "../src/Test_DFT2.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_OperationManager

# Source the wave file
do Test_OperationManager_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End