# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/Common.sv"
vlog -work work "../src/Test_NoteFinderWithData.sv"
vlog -work work "../src/NoteFinder.sv"
vlog -work work "../src/Filter.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_NoteFinderWithData

# Source the wave file
do Test_NoteFinderWithData_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End