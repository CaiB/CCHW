# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/ColorCalc.sv"
vlog -work work "../src/Test_ColorCalc.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_ColorCalc

# Source the wave file
do Test_ColorCalc_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End