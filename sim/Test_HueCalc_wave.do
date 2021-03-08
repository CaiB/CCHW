onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /HueCalc_testbench/dut/notePosition_i
add wave -noupdate -radix unsigned -childformat {{{/HueCalc_testbench/dut/note[14]} -radix decimal} {{/HueCalc_testbench/dut/note[13]} -radix decimal} {{/HueCalc_testbench/dut/note[12]} -radix decimal} {{/HueCalc_testbench/dut/note[11]} -radix decimal} {{/HueCalc_testbench/dut/note[10]} -radix decimal} {{/HueCalc_testbench/dut/note[9]} -radix decimal} {{/HueCalc_testbench/dut/note[8]} -radix decimal} {{/HueCalc_testbench/dut/note[7]} -radix decimal} {{/HueCalc_testbench/dut/note[6]} -radix decimal} {{/HueCalc_testbench/dut/note[5]} -radix decimal} {{/HueCalc_testbench/dut/note[4]} -radix decimal} {{/HueCalc_testbench/dut/note[3]} -radix decimal} {{/HueCalc_testbench/dut/note[2]} -radix decimal} {{/HueCalc_testbench/dut/note[1]} -radix decimal} {{/HueCalc_testbench/dut/note[0]} -radix decimal}} -subitemconfig {{/HueCalc_testbench/dut/note[14]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[13]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[12]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[11]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[10]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[9]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[8]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[7]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[6]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[5]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[4]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[3]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[2]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[1]} {-height 15 -radix decimal} {/HueCalc_testbench/dut/note[0]} {-height 15 -radix decimal}} /HueCalc_testbench/dut/note
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteSub
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteSub_d1
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteMult
add wave -noupdate -radix decimal /HueCalc_testbench/dut/noteMult_d1
add wave -noupdate -radix decimal /HueCalc_testbench/dut/notePreRectified
add wave -noupdate -radix unsigned /HueCalc_testbench/dut/noteRectified
add wave -noupdate -radix unsigned /HueCalc_testbench/dut/noteHue_o
add wave -noupdate /HueCalc_testbench/dut/comparator
add wave -noupdate /HueCalc_testbench/done
add wave -noupdate /HueCalc_testbench/dut/clk
add wave -noupdate /HueCalc_testbench/dut/rst
add wave -noupdate /HueCalc_testbench/dut/cycle_cntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {799081 ps} 0}
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
