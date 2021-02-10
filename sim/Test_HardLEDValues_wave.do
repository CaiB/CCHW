onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /HardLEDValues_testbench/led_rgb
add wave -noupdate /HardLEDValues_testbench/start
add wave -noupdate /HardLEDValues_testbench/done
add wave -noupdate /HardLEDValues_testbench/rst
add wave -noupdate /HardLEDValues_testbench/LEDS
add wave -noupdate /HardLEDValues_testbench/COMPLEXITY
add wave -noupdate /HardLEDValues_testbench/dut/counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {305925 ps} 0}
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
