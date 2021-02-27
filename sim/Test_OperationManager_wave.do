onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_OperationManager/clk
add wave -noupdate /Test_OperationManager/rst
add wave -noupdate /Test_OperationManager/sampleReady
add wave -noupdate /Test_OperationManager/DUT/Present
add wave -noupdate -divider Outs
add wave -noupdate /Test_OperationManager/ready
add wave -noupdate /Test_OperationManager/writeSample
add wave -noupdate -radix unsigned /Test_OperationManager/octave
add wave -noupdate /Test_OperationManager/operation
add wave -noupdate -radix unsigned /Test_OperationManager/bin
add wave -noupdate /Test_OperationManager/finishedProcessing
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10305 ps} 0}
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
WaveRestoreZoom {8305 ps} {12305 ps}
