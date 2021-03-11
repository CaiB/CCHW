# Create work library
vlib work

# Source and Testbench files
vlog -work work +define+RAM_FPGA=1 "../src/DFT2.sv"
vlog -work work "../src/Test_DFT2.sv"
vlog -work work "../src/Test_DFTWithData.sv"
vlog -work work "../src/TrigLUTs.sv"
vlog -work work "../src/FPGA/RAM_512.v"
vlog -work work "../src/FPGA/RAM_1024.v"
vlog -work work "../src/FPGA/RAM_2048.v"
vlog -work work "../src/FPGA/RAM_4096.v"
vlog -work work "../src/FPGA/RAM_8192.v"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work -Lf altera_mf_ver Test_DFT

# Source the wave file
do Test_DFTWithData_ramdebug_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End