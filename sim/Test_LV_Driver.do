# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/Common.sv"
vlog -work work "../src/LEDDriver2.sv"
vlog -work work "../src/Test_LV_Driver.sv"
vlog -work work "../src/LinearVisualizer.sv"
vlog -work work "../src/AmpPreprocessor.sv"
vlog -work work "../src/LEDCountCalc.sv"
vlog -work work "../src/ColorCalc.sv"
vlog -work work "../src/HueCalc.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work Test_LV_Driver

# Source the wave file
do Test_LV_Driver_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End