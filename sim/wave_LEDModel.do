onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /LEDModel_testbench/rgb
add wave -noupdate /LEDModel_testbench/SDO
add wave -noupdate /LEDModel_testbench/CKO
add wave -noupdate /LEDModel_testbench/SDI
add wave -noupdate /LEDModel_testbench/CKI
add wave -noupdate -expand -group internal -radix hexadecimal /LEDModel_testbench/dut/latchedReg
add wave -noupdate -expand -group internal -radix hexadecimal /LEDModel_testbench/dut/shiftReg
add wave -noupdate -expand -group internal -radix unsigned /LEDModel_testbench/dut/latchCntr
add wave -noupdate -expand -group internal -radix unsigned /LEDModel_testbench/dut/relayCntr
add wave -noupdate -expand -group internal /LEDModel_testbench/dut/relayMode
add wave -noupdate -expand -group internal /LEDModel_testbench/dut/osc
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {207 ps} 0}
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
WaveRestoreZoom {0 ps} {1058064 ns}
