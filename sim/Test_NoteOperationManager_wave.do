onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_NoteOperationManager/clk
add wave -noupdate /Test_NoteOperationManager/rst
add wave -noupdate /Test_NoteOperationManager/start
add wave -noupdate /Test_NoteOperationManager/doOperation
add wave -noupdate /Test_NoteOperationManager/clearIntermediate
add wave -noupdate -radix unsigned /Test_NoteOperationManager/activeOctave
add wave -noupdate -radix unsigned /Test_NoteOperationManager/activeNoteSlot
add wave -noupdate /Test_NoteOperationManager/finished
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {70850 ps} {78850 ps}
