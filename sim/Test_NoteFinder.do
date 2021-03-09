# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/Test_NoteFinder.sv"
vlog -work work "../src/NoteFinder.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_NoteFinder

# Source the wave file
do Test_NoteFinder_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End