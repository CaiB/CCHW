# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/HueCalc.sv"
vlog -work work "../src/Test_HueCalc.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_HueCalc

# Source the wave file
do Test_HueCalc_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End