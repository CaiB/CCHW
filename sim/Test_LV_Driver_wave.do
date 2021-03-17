onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_LV_Driver/dOut
add wave -noupdate /Test_LV_Driver/clkOut
add wave -noupdate /Test_LV_Driver/ld_done
add wave -noupdate /Test_LV_Driver/lv_start
add wave -noupdate /Test_LV_Driver/clk
add wave -noupdate /Test_LV_Driver/rst
add wave -noupdate -expand -group Driver -expand /Test_LV_Driver/DUT/ld_u/rgb
add wave -noupdate -expand -group Driver -radix unsigned -childformat {{{/Test_LV_Driver/DUT/ld_u/LEDCounts[11]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[10]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[9]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[8]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[7]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[6]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[5]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[4]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[3]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[2]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[1]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/LEDCounts[0]} -radix unsigned}} -subitemconfig {{/Test_LV_Driver/DUT/ld_u/LEDCounts[11]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[10]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[9]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[8]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[7]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[6]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[5]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[4]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[3]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[2]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[1]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/LEDCounts[0]} {-height 15 -radix unsigned}} /Test_LV_Driver/DUT/ld_u/LEDCounts
add wave -noupdate -expand -group Driver -radix unsigned /Test_LV_Driver/DUT/ld_u/WaitCntr
add wave -noupdate -expand -group Driver -radix unsigned /Test_LV_Driver/DUT/ld_u/BinCntr
add wave -noupdate -expand -group Driver -radix unsigned -childformat {{{/Test_LV_Driver/DUT/ld_u/ColorCount[5]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/ColorCount[4]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/ColorCount[3]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/ColorCount[2]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/ColorCount[1]} -radix unsigned} {{/Test_LV_Driver/DUT/ld_u/ColorCount[0]} -radix unsigned}} -subitemconfig {{/Test_LV_Driver/DUT/ld_u/ColorCount[5]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/ColorCount[4]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/ColorCount[3]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/ColorCount[2]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/ColorCount[1]} {-height 15 -radix unsigned} {/Test_LV_Driver/DUT/ld_u/ColorCount[0]} {-height 15 -radix unsigned}} /Test_LV_Driver/DUT/ld_u/ColorCount
add wave -noupdate -expand -group Driver -radix unsigned /Test_LV_Driver/DUT/ld_u/SerialCntr
add wave -noupdate -expand -group Driver -radix unsigned /Test_LV_Driver/DUT/ld_u/BinLast
add wave -noupdate -expand -group Driver /Test_LV_Driver/DUT/ld_u/Color
add wave -noupdate -expand -group Visualizer /Test_LV_Driver/DUT/lv_u/notes
add wave -noupdate {/Test_LV_Driver/DUT/lv_u/hue_proc[0]/binHueCalc_u/notePosition_i}
add wave -noupdate -radix unsigned {/Test_LV_Driver/DUT/lv_u/hue_proc[0]/binHueCalc_u/noteHue_o}
add wave -noupdate {/Test_LV_Driver/DUT/lv_u/hue_proc[1]/binHueCalc_u/notePosition_i}
add wave -noupdate -radix unsigned {/Test_LV_Driver/DUT/lv_u/hue_proc[1]/binHueCalc_u/noteHue_o}
add wave -noupdate {/Test_LV_Driver/DUT/lv_u/hue_proc[2]/binHueCalc_u/notePosition_i}
add wave -noupdate -radix decimal {/Test_LV_Driver/DUT/lv_u/hue_proc[2]/binHueCalc_u/noteHue_o}
add wave -noupdate {/Test_LV_Driver/DUT/lv_u/hue_proc[3]/binHueCalc_u/notePosition_i}
add wave -noupdate {/Test_LV_Driver/DUT/lv_u/hue_proc[3]/binHueCalc_u/noteHue_o}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2078965898 ps} 0}
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
WaveRestoreZoom {2078370354 ps} {2083213235 ps}
