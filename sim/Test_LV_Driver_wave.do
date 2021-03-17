onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_LV_Driver/dOut
add wave -noupdate /Test_LV_Driver/clkOut
add wave -noupdate /Test_LV_Driver/rgb
add wave -noupdate -radix unsigned -childformat {{{/Test_LV_Driver/LEDCounts[11]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[10]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[9]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[8]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[7]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[6]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[5]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[4]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[3]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[2]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[1]} -radix unsigned} {{/Test_LV_Driver/LEDCounts[0]} -radix unsigned}} -subitemconfig {{/Test_LV_Driver/LEDCounts[11]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[10]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[9]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[8]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[7]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[6]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[5]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[4]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[3]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[2]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[1]} {-height 15 -radix unsigned} {/Test_LV_Driver/LEDCounts[0]} {-height 15 -radix unsigned}} /Test_LV_Driver/LEDCounts
add wave -noupdate /Test_LV_Driver/ld_done
add wave -noupdate /Test_LV_Driver/lv_dv
add wave -noupdate /Test_LV_Driver/lv_start
add wave -noupdate /Test_LV_Driver/clk
add wave -noupdate /Test_LV_Driver/rst
add wave -noupdate -radix unsigned /Test_LV_Driver/ld_u/WaitCntr
add wave -noupdate /Test_LV_Driver/ld_u/ps
add wave -noupdate /Test_LV_Driver/ld_u/BinCntr
add wave -noupdate /Test_LV_Driver/ld_u/BinLast
add wave -noupdate -radix decimal /Test_LV_Driver/ld_u/ColorCount
add wave -noupdate /Test_LV_Driver/ld_u/Color
add wave -noupdate /Test_LV_Driver/lv_u/notes
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1036756390 ps} 0}
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
WaveRestoreZoom {2076017600 ps} {2084209600 ps}
