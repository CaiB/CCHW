onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /Test_PeakPlacer/binIndex
add wave -noupdate -radix unsigned /Test_PeakPlacer/left
add wave -noupdate -radix unsigned /Test_PeakPlacer/here
add wave -noupdate -radix unsigned /Test_PeakPlacer/right
add wave -noupdate -radix binary /Test_PeakPlacer/peakPosition
add wave -noupdate /Test_PeakPlacer/peakPositionR
add wave -noupdate /Test_PeakPlacer/ExpectedOutput
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {850 ps} 0}
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
WaveRestoreZoom {500 ps} {2500 ps}
