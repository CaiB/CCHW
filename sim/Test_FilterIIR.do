# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/Common.sv"
vlog -work work "../src/Filter.sv"
vlog -work work "../src/Test_Filter.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_FilterIIR

# Source the wave file
do Test_FilterIIR_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End