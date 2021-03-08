onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /HueCalc_testbench/dut/notePosition_i
add wave -noupdate -radix decimal /HueCalc_testbench/dut/note
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteSub
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteMult
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteRectified
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteHue_o
add wave -noupdate /HueCalc_testbench/dut/comparator
add wave -noupdate /HueCalc_testbench/dut/clk
add wave -noupdate /HueCalc_testbench/dut/rst
add wave -noupdate /HueCalc_testbench/dut/cycle_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {168927 ps} 0}
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
