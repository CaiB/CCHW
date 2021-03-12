# Create work library
vlib work

# Source and Testbench files
vlog -work work +define+RAM_FPGA=1 "../src/DFT.sv"
vlog -work work "../src/Test_FullSystem.sv"
vlog -work work "../src/TrigLUTs.sv"
vlog -work work "../src/NoteFinder.sv"
vlog -work work "../src/ColorChordTop.sv"
vlog -work work "../src/FPGA/RAM_512.v"
vlog -work work "../src/FPGA/RAM_1024.v"
vlog -work work "../src/FPGA/RAM_2048.v"
vlog -work work "../src/FPGA/RAM_4096.v"
vlog -work work "../src/FPGA/RAM_8192.v"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work -Lf altera_mf_ver Test_FullSystem

# Source the wave file
do Test_FullSystem_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End