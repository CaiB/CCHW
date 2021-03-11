onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /LEDDriver2_testbench/dOut
add wave -noupdate /LEDDriver2_testbench/clkOut
add wave -noupdate /LEDDriver2_testbench/done
add wave -noupdate /LEDDriver2_testbench/rgb
add wave -noupdate -radix unsigned -childformat {{{/LEDDriver2_testbench/LEDCounts[11]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[10]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[9]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[8]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[7]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[6]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[5]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[4]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[3]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[2]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[1]} -radix unsigned} {{/LEDDriver2_testbench/LEDCounts[0]} -radix unsigned}} -subitemconfig {{/LEDDriver2_testbench/LEDCounts[11]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[10]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[9]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[8]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[7]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[6]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[5]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[4]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[3]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[2]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[1]} {-height 15 -radix unsigned} {/LEDDriver2_testbench/LEDCounts[0]} {-height 15 -radix unsigned}} /LEDDriver2_testbench/LEDCounts
add wave -noupdate /LEDDriver2_testbench/clk
add wave -noupdate /LEDDriver2_testbench/rst
add wave -noupdate -radix unsigned /LEDDriver2_testbench/dut/WaitCntr
add wave -noupdate -radix unsigned /LEDDriver2_testbench/dut/BinCntr
add wave -noupdate -radix unsigned /LEDDriver2_testbench/dut/SerialCntr
add wave -noupdate /LEDDriver2_testbench/dut/Color
add wave -noupdate -radix unsigned /LEDDriver2_testbench/dut/ColorCount
add wave -noupdate /LEDDriver2_testbench/dut/ps
add wave -noupdate /LEDDriver2_testbench/dut/ns
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40 ps} 0}
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
WaveRestoreZoom {0 ps} {2 ns}
