onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_OctaveStorageRAM/clk
add wave -noupdate /Test_OctaveStorageRAM/rst
add wave -noupdate -radix hexadecimal /Test_OctaveStorageRAM/newSample
add wave -noupdate /Test_OctaveStorageRAM/writeSample
add wave -noupdate -radix hexadecimal /Test_OctaveStorageRAM/sample0
add wave -noupdate -radix hexadecimal /Test_OctaveStorageRAM/sample1
add wave -noupdate -radix hexadecimal /Test_OctaveStorageRAM/oldestSample
add wave -noupdate -divider Internal
add wave -noupdate /Test_OctaveStorageRAM/DUT/Present
add wave -noupdate -radix unsigned /Test_OctaveStorageRAM/DUT/Address
add wave -noupdate /Test_OctaveStorageRAM/DUT/DataValid
add wave -noupdate -radix hexadecimal /Test_OctaveStorageRAM/DUT/RAMIn
add wave -noupdate -radix hexadecimal /Test_OctaveStorageRAM/DUT/RAMOut
add wave -noupdate -radix hexadecimal /Test_OctaveStorageRAM/DUT/OldRegOut
add wave -noupdate /Test_OctaveStorageRAM/DUT/RAMWrite
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {615600 ps} 0}
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
WaveRestoreZoom {613200 ps} {617200 ps}
