onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_FullSystem/clk
add wave -noupdate /Test_FullSystem/rst
add wave -noupdate -radix decimal /Test_FullSystem/inputSample
add wave -noupdate /Test_FullSystem/sampleReady
add wave -noupdate -expand /Test_FullSystem/peaksOut
add wave -noupdate -radix unsigned /Test_FullSystem/DUT/TheDFT/ActiveOctave
add wave -noupdate -radix unsigned /Test_FullSystem/DUT/TheDFT/CurrentOctaveBinIndex
add wave -noupdate /Test_FullSystem/RegPeakPositionsR
add wave -noupdate -radix unsigned /Test_FullSystem/DUT/TheNF/RegPeakAmplitudes
add wave -noupdate /Test_FullSystem/DUT/TheNF/RegPeaksValid
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
WaveRestoreZoom {4495450 ps} {4496450 ps}
