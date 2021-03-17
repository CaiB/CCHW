onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /Test_LEDModel/rgb
add wave -noupdate /Test_LEDModel/SDO
add wave -noupdate /Test_LEDModel/CKO
add wave -noupdate /Test_LEDModel/SDI
add wave -noupdate /Test_LEDModel/CKI
add wave -noupdate -expand -group internal -radix hexadecimal /Test_LEDModel/dut/latchedReg
add wave -noupdate -expand -group internal -radix hexadecimal /Test_LEDModel/dut/shiftReg
add wave -noupdate -expand -group internal -radix unsigned /Test_LEDModel/dut/latchCntr
add wave -noupdate -expand -group internal -radix unsigned /Test_LEDModel/dut/relayCntr
add wave -noupdate -expand -group internal /Test_LEDModel/dut/relayMode
add wave -noupdate -expand -group internal /Test_LEDModel/dut/osc
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
