onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_OperationCounter/clk
add wave -noupdate /Test_OperationCounter/rst
add wave -noupdate /Test_OperationCounter/enable
add wave -noupdate -radix unsigned /Test_OperationCounter/octave
add wave -noupdate /Test_OperationCounter/operation
add wave -noupdate -radix unsigned /Test_OperationCounter/bin
add wave -noupdate /Test_OperationCounter/finished
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {48108 ps} 0}
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
WaveRestoreZoom {41500 ps} {49500 ps}
