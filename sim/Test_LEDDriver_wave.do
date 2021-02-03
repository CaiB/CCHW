onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /LEDDriver_testbench/dOut
add wave -noupdate /LEDDriver_testbench/clkOut
add wave -noupdate /LEDDriver_testbench/done
add wave -noupdate /LEDDriver_testbench/start
add wave -noupdate -radix hexadecimal /LEDDriver_testbench/led_rgb
add wave -noupdate /LEDDriver_testbench/rst
add wave -noupdate /LEDDriver_testbench/clk
add wave -noupdate -radix unsigned {/LEDDriver_testbench/dut/waitCntr[13]}
add wave -noupdate -radix unsigned -childformat {{{/LEDDriver_testbench/dut/waitCntr[13]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[12]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[11]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[10]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[9]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[8]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[7]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[6]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[5]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[4]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[3]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[2]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[1]} -radix unsigned} {{/LEDDriver_testbench/dut/waitCntr[0]} -radix unsigned}} -subitemconfig {{/LEDDriver_testbench/dut/waitCntr[13]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[12]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[11]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[10]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[9]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[8]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[7]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[6]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[5]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[4]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[3]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[2]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[1]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/waitCntr[0]} {-height 15 -radix unsigned}} /LEDDriver_testbench/dut/waitCntr
add wave -noupdate -radix unsigned -childformat {{{/LEDDriver_testbench/dut/loadCntr[5]} -radix unsigned} {{/LEDDriver_testbench/dut/loadCntr[4]} -radix unsigned} {{/LEDDriver_testbench/dut/loadCntr[3]} -radix unsigned} {{/LEDDriver_testbench/dut/loadCntr[2]} -radix unsigned} {{/LEDDriver_testbench/dut/loadCntr[1]} -radix unsigned} {{/LEDDriver_testbench/dut/loadCntr[0]} -radix unsigned}} -subitemconfig {{/LEDDriver_testbench/dut/loadCntr[5]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/loadCntr[4]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/loadCntr[3]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/loadCntr[2]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/loadCntr[1]} {-height 15 -radix unsigned} {/LEDDriver_testbench/dut/loadCntr[0]} {-height 15 -radix unsigned}} /LEDDriver_testbench/dut/loadCntr
add wave -noupdate /LEDDriver_testbench/dut/ps
add wave -noupdate /LEDDriver_testbench/loadColor/rgb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {652274 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {651847 ps} {659754 ps}
