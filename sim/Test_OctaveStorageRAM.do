# Create work library
vlib work

# Source and Testbench files
vlog -work work +define+RAM_FPGA=1 "../src/DFT2.sv"
vlog -work work "../src/Test_DFT2.sv"
vlog -work work "../src/FPGA/RAM_512.v"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work -Lf altera_mf_ver Test_OctaveStorageRAM

# Source the wave file
do Test_OctaveStorageRAM_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End