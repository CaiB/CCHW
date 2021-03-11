onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /LV_Driver_testbench/dOut
add wave -noupdate /LV_Driver_testbench/clkOut
add wave -noupdate /LV_Driver_testbench/rgb
add wave -noupdate -radix unsigned -childformat {{{/LV_Driver_testbench/LEDCounts[11]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[10]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[9]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[8]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[7]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[6]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[5]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[4]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[3]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[2]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[1]} -radix unsigned} {{/LV_Driver_testbench/LEDCounts[0]} -radix unsigned}} -subitemconfig {{/LV_Driver_testbench/LEDCounts[11]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[10]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[9]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[8]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[7]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[6]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[5]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[4]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[3]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[2]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[1]} {-height 15 -radix unsigned} {/LV_Driver_testbench/LEDCounts[0]} {-height 15 -radix unsigned}} /LV_Driver_testbench/LEDCounts
add wave -noupdate -radix decimal -childformat {{{/LV_Driver_testbench/noteAmplitudes[11]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[10]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[9]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[8]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[7]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[6]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[5]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[4]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[3]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[2]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[1]} -radix decimal} {{/LV_Driver_testbench/noteAmplitudes[0]} -radix decimal}} -subitemconfig {{/LV_Driver_testbench/noteAmplitudes[11]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[10]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[9]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[8]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[7]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[6]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[5]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[4]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[3]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[2]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[1]} {-height 15 -radix decimal} {/LV_Driver_testbench/noteAmplitudes[0]} {-height 15 -radix decimal}} /LV_Driver_testbench/noteAmplitudes
add wave -noupdate -radix decimal -childformat {{{/LV_Driver_testbench/notePositions[11]} -radix decimal} {{/LV_Driver_testbench/notePositions[10]} -radix decimal} {{/LV_Driver_testbench/notePositions[9]} -radix decimal} {{/LV_Driver_testbench/notePositions[8]} -radix decimal} {{/LV_Driver_testbench/notePositions[7]} -radix decimal} {{/LV_Driver_testbench/notePositions[6]} -radix decimal} {{/LV_Driver_testbench/notePositions[5]} -radix decimal} {{/LV_Driver_testbench/notePositions[4]} -radix decimal} {{/LV_Driver_testbench/notePositions[3]} -radix decimal} {{/LV_Driver_testbench/notePositions[2]} -radix decimal} {{/LV_Driver_testbench/notePositions[1]} -radix decimal} {{/LV_Driver_testbench/notePositions[0]} -radix decimal}} -subitemconfig {{/LV_Driver_testbench/notePositions[11]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[10]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[9]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[8]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[7]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[6]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[5]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[4]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[3]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[2]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[1]} {-height 15 -radix decimal} {/LV_Driver_testbench/notePositions[0]} {-height 15 -radix decimal}} /LV_Driver_testbench/notePositions
add wave -noupdate /LV_Driver_testbench/ld_done
add wave -noupdate /LV_Driver_testbench/lv_dv
add wave -noupdate /LV_Driver_testbench/lv_start
add wave -noupdate /LV_Driver_testbench/clk
add wave -noupdate /LV_Driver_testbench/rst
add wave -noupdate -radix unsigned /LV_Driver_testbench/ld_u/WaitCntr
add wave -noupdate /LV_Driver_testbench/ld_u/ps
add wave -noupdate /LV_Driver_testbench/ld_u/Color
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {656299562 ps} 0}
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
WaveRestoreZoom {649884140 ps} {658076140 ps}
