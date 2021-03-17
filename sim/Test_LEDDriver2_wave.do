onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_LEDDriver2/dOut
add wave -noupdate /Test_LEDDriver2/clkOut
add wave -noupdate /Test_LEDDriver2/done
add wave -noupdate /Test_LEDDriver2/rgb
add wave -noupdate -radix unsigned -childformat {{{/Test_LEDDriver2/LEDCounts[11]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[10]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[9]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[8]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[7]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[6]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[5]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[4]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[3]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[2]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[1]} -radix unsigned} {{/Test_LEDDriver2/LEDCounts[0]} -radix unsigned}} -subitemconfig {{/Test_LEDDriver2/LEDCounts[11]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[10]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[9]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[8]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[7]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[6]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[5]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[4]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[3]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[2]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[1]} {-height 15 -radix unsigned} {/Test_LEDDriver2/LEDCounts[0]} {-height 15 -radix unsigned}} /Test_LEDDriver2/LEDCounts
add wave -noupdate /Test_LEDDriver2/clk
add wave -noupdate /Test_LEDDriver2/rst
add wave -noupdate -radix unsigned /Test_LEDDriver2/dut/WaitCntr
add wave -noupdate -radix unsigned /Test_LEDDriver2/dut/BinCntr
add wave -noupdate -radix unsigned /Test_LEDDriver2/dut/SerialCntr
add wave -noupdate /Test_LEDDriver2/dut/Color
add wave -noupdate -radix unsigned /Test_LEDDriver2/dut/ColorCount
add wave -noupdate /Test_LEDDriver2/dut/ps
add wave -noupdate /Test_LEDDriver2/dut/ns
add wave -noupdate -radix unsigned -childformat {{{/Test_LEDDriver2/dut/LEDCountsRegistered[11]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[10]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[9]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[8]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[7]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[6]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[5]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[4]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[3]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[2]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[1]} -radix unsigned} {{/Test_LEDDriver2/dut/LEDCountsRegistered[0]} -radix unsigned}} -subitemconfig {{/Test_LEDDriver2/dut/LEDCountsRegistered[11]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[10]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[9]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[8]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[7]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[6]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[5]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[4]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[3]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[2]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[1]} {-height 15 -radix unsigned} {/Test_LEDDriver2/dut/LEDCountsRegistered[0]} {-height 15 -radix unsigned}} /Test_LEDDriver2/dut/LEDCountsRegistered
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1512538725 ps} 0}
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
WaveRestoreZoom {1511515200 ps} {1513563200 ps}
