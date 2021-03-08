onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned -childformat {{{/LEDCountCalc_testbench/dut/noteAmplitudes_i[11]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[10]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[9]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[8]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[7]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[6]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[5]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[4]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[3]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[2]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[1]} -radix unsigned} {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[0]} -radix unsigned}} -expand -subitemconfig {{/LEDCountCalc_testbench/dut/noteAmplitudes_i[11]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[10]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[9]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[8]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[7]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[6]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[5]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[4]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[3]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[2]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[1]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/noteAmplitudes_i[0]} {-height 15 -radix unsigned}} /LEDCountCalc_testbench/dut/noteAmplitudes_i
add wave -noupdate -radix unsigned /LEDCountCalc_testbench/dut/amplitudeSumNew_i
add wave -noupdate -radix unsigned /LEDCountCalc_testbench/dut/thresholdAmplitude
add wave -noupdate -radix unsigned -childformat {{{/LEDCountCalc_testbench/dut/LEDCount[10]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[9]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[8]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[7]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[6]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[5]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[4]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[3]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[2]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[1]} -radix unsigned} {{/LEDCountCalc_testbench/dut/LEDCount[0]} -radix unsigned}} -expand -subitemconfig {{/LEDCountCalc_testbench/dut/LEDCount[10]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[9]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[8]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[7]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[6]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[5]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[4]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[3]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[2]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[1]} {-height 15 -radix unsigned} {/LEDCountCalc_testbench/dut/LEDCount[0]} {-height 15 -radix unsigned}} /LEDCountCalc_testbench/dut/LEDCount
add wave -noupdate /LEDCountCalc_testbench/data_v
add wave -noupdate /LEDCountCalc_testbench/dut/clk
add wave -noupdate /LEDCountCalc_testbench/dut/rst
add wave -noupdate /LEDCountCalc_testbench/dut/cycle_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {79718 ps} 0}
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
