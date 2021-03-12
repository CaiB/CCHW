# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/DFT.sv"
vlog -work work "../src/Test_DFT.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_OctaveSelector

# Source the wave file
do Test_OctaveSelector_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End