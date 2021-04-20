onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Test_NoteAssociator/clk
add wave -noupdate /Test_NoteAssociator/rst
add wave -noupdate /Test_NoteAssociator/start
add wave -noupdate /Test_NoteAssociator/finished
add wave -noupdate -divider Internal
add wave -noupdate /Test_NoteAssociator/ASSDISTR
add wave -noupdate -radix unsigned /Test_NoteAssociator/DUT/PeakCtr
add wave -noupdate -radix unsigned /Test_NoteAssociator/DUT/NoteCtr
add wave -noupdate /Test_NoteAssociator/DUT/Present
add wave -noupdate -divider {Fresh Inputs}
add wave -noupdate /Test_NoteAssociator/newPeakPosR
add wave -noupdate /Test_NoteAssociator/newPeaks
add wave -noupdate -divider Current
add wave -noupdate -expand -subitemconfig {{/Test_NoteAssociator/DUT/AssociatedNotes[1]} {-childformat {{{/Test_NoteAssociator/DUT/AssociatedNotes[1].amplitude} -radix unsigned}}} {/Test_NoteAssociator/DUT/AssociatedNotes[1].amplitude} {-radix unsigned} {/Test_NoteAssociator/DUT/AssociatedNotes[4]} {-childformat {{{/Test_NoteAssociator/DUT/AssociatedNotes[4].amplitude} -radix unsigned}}} {/Test_NoteAssociator/DUT/AssociatedNotes[4].amplitude} {-radix unsigned}} /Test_NoteAssociator/DUT/AssociatedNotes
add wave -noupdate -radix unsigned /Test_NoteAssociator/DUT/AssociatingWriteLoc
add wave -noupdate /Test_NoteAssociator/DUT/DoAssociatingWrite
add wave -noupdate /Test_NoteAssociator/DUT/CurrentlyAssociating
add wave -noupdate /Test_NoteAssociator/DUT/HasEmptyNoteSlot
add wave -noupdate -radix unsigned /Test_NoteAssociator/DUT/FirstEmptyNote
add wave -noupdate /Test_NoteAssociator/DUT/AssociateHere
add wave -noupdate /Test_NoteAssociator/DUT/PeakHasAssociated
add wave -noupdate -divider {New Set}
add wave -noupdate /Test_NoteAssociator/DUT/NoteHasBeenAssociatedTo
add wave -noupdate /Test_NoteAssociator/DUT/RegToExisting
add wave -noupdate -expand -subitemconfig {{/Test_NoteAssociator/DUT/ExistingNotes[0]} {-height 15 -childformat {{{/Test_NoteAssociator/DUT/ExistingNotes[0].amplitude} -radix unsigned}}} {/Test_NoteAssociator/DUT/ExistingNotes[0].amplitude} {-height 15 -radix unsigned} {/Test_NoteAssociator/DUT/ExistingNotes[1]} {-height 15 -childformat {{{/Test_NoteAssociator/DUT/ExistingNotes[1].amplitude} -radix unsigned}}} {/Test_NoteAssociator/DUT/ExistingNotes[1].amplitude} {-height 15 -radix unsigned} {/Test_NoteAssociator/DUT/ExistingNotes[2]} {-height 15 -childformat {{{/Test_NoteAssociator/DUT/ExistingNotes[2].amplitude} -radix unsigned}}} {/Test_NoteAssociator/DUT/ExistingNotes[2].amplitude} {-height 15 -radix unsigned} {/Test_NoteAssociator/DUT/ExistingNotes[3]} {-height 15 -childformat {{{/Test_NoteAssociator/DUT/ExistingNotes[3].amplitude} -radix unsigned}}} {/Test_NoteAssociator/DUT/ExistingNotes[3].amplitude} {-height 15 -radix unsigned} {/Test_NoteAssociator/DUT/ExistingNotes[4]} {-height 15 -childformat {{{/Test_NoteAssociator/DUT/ExistingNotes[4].amplitude} -radix unsigned}}} {/Test_NoteAssociator/DUT/ExistingNotes[4].amplitude} {-height 15 -radix unsigned}} /Test_NoteAssociator/DUT/ExistingNotes
add wave -noupdate -divider {Smoothed Output}
add wave -noupdate -expand /Test_NoteAssociator/outPositionsR
add wave -noupdate /Test_NoteAssociator/outNotes
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {32948 ps} 0}
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
WaveRestoreZoom {32600 ps} {34600 ps}
