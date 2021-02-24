# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/DFT2.sv"
vlog -work work "../src/Test_DFT2.sv"
vlog -work work "../src/Test_DFTWithData.sv"
vlog -work work "../src/TrigLUTs.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_DFT

# Source the wave file
do Test_DFTWithData_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End