onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ColorCalc_testbench/dut/LEDLimit
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteAmplitude_i
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteAmplitudeFast_i
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteHue_i
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/hueDivided
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/hueWhole
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/hueWhole_d1
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/hueWhole_d2
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/hueDec
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/hueDec_d1
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteAmplitude
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteAmplitudeMult
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteAmplitudeDec
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteAmplitudeLimited
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/noteAmplitudeLimited_d1
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/colorValueXHue
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/colorValueXHuex
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/colorValueMax
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/colorValueXHue_d1
add wave -noupdate -radix unsigned /ColorCalc_testbench/dut/colorValueXHuex_d1
add wave -noupdate -radix hexadecimal /ColorCalc_testbench/dut/rgb
add wave -noupdate /ColorCalc_testbench/data_v
add wave -noupdate /ColorCalc_testbench/rst
add wave -noupdate /ColorCalc_testbench/clk
add wave -noupdate /ColorCalc_testbench/dut/cycle_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {98699 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2048 ns}
