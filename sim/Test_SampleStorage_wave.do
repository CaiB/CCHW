onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_SampleStorage/clk
add wave -noupdate -radix hexadecimal /Test_SampleStorage/in
add wave -noupdate -radix hexadecimal /Test_SampleStorage/outFirst
add wave -noupdate -radix hexadecimal {/Test_SampleStorage/DUT/Inter[2]}
add wave -noupdate -radix hexadecimal {/Test_SampleStorage/DUT/Inter[3]}
add wave -noupdate -radix hexadecimal {/Test_SampleStorage/DUT/Inter[4]}
add wave -noupdate -radix hexadecimal {/Test_SampleStorage/DUT/Inter[5]}
add wave -noupdate -radix hexadecimal /Test_SampleStorage/outLast
add wave -noupdate -divider {Reg Contents}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {402 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
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
WaveRestoreZoom {0 ps} {943 ps}
