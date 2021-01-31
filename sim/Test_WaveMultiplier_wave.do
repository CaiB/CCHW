onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_WaveMultiplier/clk
add wave -noupdate /Test_WaveMultiplier/enableIncr
add wave -noupdate -radix decimal /Test_WaveMultiplier/in
add wave -noupdate -radix decimal /Test_WaveMultiplier/sinValue
add wave -noupdate -radix decimal /Test_WaveMultiplier/cosValue
add wave -noupdate -radix decimal /Test_WaveMultiplier/DUT/productSin
add wave -noupdate -radix decimal /Test_WaveMultiplier/DUT/productCos
add wave -noupdate -radix decimal /Test_WaveMultiplier/outMagnitude
add wave -noupdate -radix unsigned /Test_WaveMultiplier/SinTable/position
add wave -noupdate -radix unsigned /Test_WaveMultiplier/bin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2002 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {1445 ps} {2346 ps}
