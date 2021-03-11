# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/LEDDriver2.sv"
vlog -work work "../src/LinearVisualizer.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work LV_Driver_testbench

# Source the wave file
do Test_LV_Driver_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End