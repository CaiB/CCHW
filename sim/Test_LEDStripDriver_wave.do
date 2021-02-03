onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /LEDStripDriver_testbench/led_rgb
add wave -noupdate {/LEDStripDriver_testbench/SDIO[0]}
add wave -noupdate {/LEDStripDriver_testbench/CKIO[0]}
add wave -noupdate /LEDStripDriver_testbench/start
add wave -noupdate /LEDStripDriver_testbench/clk
add wave -noupdate /LEDStripDriver_testbench/rst
add wave -noupdate /LEDStripDriver_testbench/SDIO
add wave -noupdate /LEDStripDriver_testbench/CKIO
add wave -noupdate /LEDStripDriver_testbench/rgb
add wave -noupdate /LEDStripDriver_testbench/driver/ps
add wave -noupdate /LEDStripDriver_testbench/driver/loadCntr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {653414 ps} 0}
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
