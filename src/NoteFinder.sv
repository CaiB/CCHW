import CCHW::*;

module NoteFinder
#(parameter N = 16, parameter BPO = 24, parameter OCT = 5, parameter BINS = OCT*BPO, parameter FPF = 10)
(
    output Note notes [0:11],
    output logic peaksOut [0:11], // mostly for debugging purposes
    output logic finished,
    input logic unsigned [N-1:0] dftBins [0:BINS-1],
    input logic [9:0] minThreshold,
    input logic startCycle,
    input logic clk, rst
);
    genvar i;

    // Pre-process DFT input data
        // Shift by some value (amplify)
        //TODO IIR each bin
    
    // Find maximum of all bins
    logic [N-1:0] OverallMaxBinVal;
    FindMax120Approx #(.N(N)) MaxFinder(.maxValue(OverallMaxBinVal), .values(dftBins)); // TODO swap for other input

    // Determine minimum threshold for peaks
    // TODO: Tweak this as needed
    logic [N-1:0] PeakThreshold;
    assign PeakThreshold = (OverallMaxBinVal >>> 3) | {minThreshold, '0};

    // TODO Smooth adjacent bins (needed?)

    // Detect peaks
    // -> Positions are now 0-119
    // -> Up to 60 peaks max =ceil(BINS/2)
    logic BinHasPeak [0:BINS-1]; // TODO: change input
    generate
        for(i = 1; i < BINS-1; i++)
        begin : PeakDetectors
            PeakDetector #(.N(N)) PeakDet(.isPeak(BinHasPeak[i]), .left(dftBins[i - 1]), .right(dftBins[i + 1]), .here(dftBins[i]), .threshold(PeakThreshold));
        end
    endgenerate
    PeakDetector #(.N(N)) PeakDetBot(.isPeak(BinHasPeak[0]), .left('0), .right(dftBins[1]), .here(dftBins[0]), .threshold(PeakThreshold));
    PeakDetector #(.N(N)) PeakDetTop(.isPeak(BinHasPeak[119]), .left(dftBins[118]), .right('0), .here(dftBins[119]), .threshold(PeakThreshold));

    // Operation manager
    logic [3:0] ActivePeakSlot;
    logic [$clog2(OCT)-1:0] ActiveOctave;
    logic PeaksFinished, DoPeakOperation, ClearPeaks;
    NoteOperationManager #(.OCT(OCT)) OpMgr(.activeNoteSlot(ActivePeakSlot), .activeOctave(ActiveOctave), .finished(PeaksFinished), .doOperation(DoPeakOperation), .clearIntermediate(ClearPeaks), .start(startCycle), .clk, .rst);

    // Adjust peak location within bin depending on surroundings (turn isPeak into numeric positions)
    // -> Positions returned are 0.0-23.999, so octaves are also soft-merged. qty up to 60 (BINS/2)
    localparam NoteFPW = $clog2(BPO);
    localparam NoteFPF = 16 - NoteFPW;

    // This section assumes there's 2 bins per note.
    logic [$clog2(BINS)-1:0] CurrentBinLeft, CurrentBinRight;
    assign CurrentBinLeft = (ActiveOctave * BPO) + ({ActivePeakSlot, 1'b0}); // index of the left bin we're looking at
    assign CurrentBinRight = CurrentBinLeft + 1'd1; // index of the right bin we're looking at
    logic PeakSideIsL, PeakHere;
    assign PeakSideIsL = BinHasPeak[CurrentBinLeft]; // whether there's a peak in the left bin of the 2 we're looking at
    assign PeakHere = BinHasPeak[CurrentBinLeft] || BinHasPeak[CurrentBinRight]; // whether the active 2 bins have a peak at all

    logic [(NoteFPW + NoteFPF)-1:0] NoteDistPosition;
    PeakPlacer #(.N(N), .BPO(BPO), .FPW(NoteFPW), .FPF(NoteFPF)) PeakPlace(.peakPosition(NoteDistPosition),
        .binIndex(PeakSideIsL ? ({ActivePeakSlot, 1'b0}) : ({ActivePeakSlot, 1'b0} + 1'd1)),
        .left(PeakSideIsL ? (CurrentBinLeft == '0 ? '0 : dftBins[CurrentBinLeft - 1'd1]) : dftBins[CurrentBinLeft]),
        .right(PeakSideIsL ? dftBins[CurrentBinRight] : (CurrentBinRight == BINS-1 ? '0 : dftBins[CurrentBinRight + 1'd1])),
        .here(PeakSideIsL ? dftBins[CurrentBinLeft] : dftBins[CurrentBinRight]));

    // Note: each slot spans 2 bins of storage
    logic [N-1:0] SavedPeakPositions [0:11], SavedPeakAmplitudes [0:11]; // the currently saved peak's info
    logic [N-1:0] NewPeakPosition, NewPeakAmplitude; // new peak info that will get written
    logic SavedPeaksValid [0:11]; // whether each existing peak is valid
    logic NewPeakValid, WritePeak; // whether new peak data is valid, and whether to write new data

    PeakMergerItr #(.N(N)) PeakMerge(.outPos(NewPeakPosition), .outAmp(NewPeakAmplitude),
        .outValid(NewPeakValid), .doRegWrite(WritePeak),
        .isPeak(PeakHere),
        .peakPosition(NoteDistPosition), .peakAmp(PeakSideIsL ? dftBins[CurrentBinLeft] : dftBins[CurrentBinRight]),
        .regPos(SavedPeakPositions[ActivePeakSlot]), .regAmp(SavedPeakAmplitudes[ActivePeakSlot]), .regValid(SavedPeaksValid[ActivePeakSlot]));

    // Re-registered versions of "Saved" signals, for placement into next sample-pipeline stage
    logic [N-1:0] RegPeakPositions [0:11], RegPeakAmplitudes [0:11];
    logic RegPeaksValid [0:11];
    Note NewPeaks [0:11];
   
    generate
        for(i = 0; i < 12; i++)
        begin : PeakStorage
            // Stores the current peaks. Each slot gets filled with a peak when one is found in the correct location.
            // If more get found in later cycles from higher octaves, the values get updated with a weighted average of (before + new).
            PeakRegister #(.N(N)) PeakReg(.amp(SavedPeakAmplitudes[i]), .pos(SavedPeakPositions[i]), .hasPeak(SavedPeaksValid[i]), .ampIn(NewPeakAmplitude), .posIn(NewPeakPosition), .peakIn(NewPeakValid), .write(WritePeak && DoPeakOperation && ActivePeakSlot == i), .clk, .rst(rst || ClearPeaks));

            // Re-registered version of previous data, only updated once each sample is finished processing. Used as note association is a second sample-pipeline stage.
            PeakRegister #(.N(N)) PeakReg2(.amp(RegPeakAmplitudes[i]), .pos(RegPeakPositions[i]), .hasPeak(RegPeaksValid[i]), .ampIn(SavedPeakAmplitudes[i]), .posIn(SavedPeakPositions[i]), .peakIn(SavedPeaksValid[i]), .write(PeaksFinished), .clk, .rst);

            // For input to the associator
            assign NewPeaks[i].position = RegPeakPositions[i];
            assign NewPeaks[i].amplitude = RegPeakAmplitudes[i];
            assign NewPeaks[i].valid = RegPeaksValid[i];
        end
    endgenerate

    assign peaksOut = RegPeaksValid;

    // Associate peaks to existing notes, shifting them if needed
    // Create new notes if peaks don't have corresponding note
    // Decay notes not associated to
    //   -> notes max qty 12 (BPO/2)
    //   all done by the associator

    // TODO connect finished elsewhere
    NoteAssociator #(.N(N), .FPF(FPF)) Associator(.outNotes(notes), .finished, .newPeaks(NewPeaks), .start(PeaksFinished), .clk, .rst);
endmodule

module NoteAssociator
#(parameter N = 16, parameter FPF = 10)
(
    output Note outNotes [0:11],
    output logic finished,
    input Note newPeaks [0:11],
    input logic start,
    input logic clk, rst
);
    localparam ASSDIST = 16'b1111 << (FPF - 5); // Association distance of peak -> note. const 0.47
    localparam DECAYSHIFT = 9; // How much an unassociated note should decay by each time. -1 -> 2x as much decay, +1 -> 1/2 as much decay

    // Peaks come in through newPeaks. They get analyzed, and associated/merged into existing notes. This new set of notes is stored in AssociatedNotes.
    // Once notes are associated, they get smoothed and registed to the output, ExistingNotes.
    Note AssociatedNotes [0:11], ExistingNotes [0:11];
    assign outNotes = ExistingNotes;

    logic RegToExisting;
    logic [3:0] AssociatingWriteLoc;
    logic DoAssociatingWrite;
    Note CurrentlyAssociating;

    logic [11:0] AssociatedNotesValid, ExistingNotesValid; // Just a shorthand way to access all of ___Notes[*].valid

    genvar i;
    generate
        for(i = 0; i < 12; i++)
        begin: MakeCurrentNoteRegs
            NoteRegister Current(.out(ExistingNotes[i]), .in(AssociatedNotes[i]), .write(RegToExisting), .clk, .rst);
            NoteRegister New(.out(AssociatedNotes[i]), .in(CurrentlyAssociating), .write(DoAssociatingWrite && AssociatingWriteLoc == i), .clk, .rst);
            assign AssociatedNotesValid[i] = AssociatedNotes[i].valid;
            assign ExistingNotesValid[i] = ExistingNotes[i].valid;
        end
    endgenerate

    // General procedure:
    // Wait for data
    // Associate new peaks to existing notes
    // Wait extra cycle sfor weighted average to compute?
    // Add notes for peaks that do not have a place to associate to
    // Decay notes that have not been associated to this cycle
    typedef enum { WAIT, ASSOC, WAVGHOLD, NEWNOTES, DECAYNOTES, FINISH, XXX } NoteAssState;
    NoteAssState Present, Next;

    logic [3:0] PeakCtr, NoteCtr; // counts 0~11 each for every possible combination
    logic [11:0] PeakHasAssociated, NoteHasBeenAssociatedTo;

    logic AssociateHere; // whether the current location is suitable for the peak to associate
    logic [3:0] FirstEmptyNote; // the first empty note slot we can use for a new peak
    logic HasEmptyNoteSlot;

    //PeakWAvg #(.N(N)) Averager(.peakAmp(NewNoteAmp), .peakPos(NewNotePos), .in0Amp(outAmplitudes[NoteCtr]), .in0Pos(outPositions[NoteCtr]), .in1Amp(newPeakAmp[PeakCtr]), .in1Pos(newPeakPos[PeakCtr]));

    always_ff @(posedge clk, posedge rst) // State register
        if(rst) Present <= WAIT;
        else Present <= Next;
    
    always_comb // Next state
    begin
        Next = XXX;
        case(Present)
            WAIT: if(start) Next = ASSOC;
                  else Next = WAIT; // @LB
            ASSOC: if(NoteCtr == 11 && PeakCtr == 11) Next = NEWNOTES;
                  else Next = ASSOC; // @LB
            NEWNOTES: if(NoteCtr == 11) Next = DECAYNOTES;
                      else Next = NEWNOTES; // @LB
            DECAYNOTES: if(NoteCtr == 11) Next = FINISH;
                        else Next = DECAYNOTES; // @LB
            FINISH: Next = WAIT;
            default: Next = XXX;
        endcase
    end

    always_comb // Combinational outputs
    begin // TODO handle wraparound on ends
        AssociateHere = (~PeakHasAssociated[PeakCtr] && // we not yet found a note to associate to
                        ((ExistingNotes[NoteCtr].position - ASSDIST) < newPeaks[PeakCtr].position) && // peak is within range on left of note
                        ((ExistingNotes[NoteCtr].position + ASSDIST) > newPeaks[PeakCtr].position)); // peak is within range on right of note
        HasEmptyNoteSlot = '1;
        // Not supported by Quartus D:
        // case(AssociatedNotesValid) inside
        // casez is apparently fine and the rest of the block remains the same.
        // casez is a bit worse for debugging in simulation, but should work OK
        casez(AssociatedNotesValid)
            12'b???????????0: FirstEmptyNote = 4'd0;
            12'b??????????01: FirstEmptyNote = 4'd1;
            12'b?????????011: FirstEmptyNote = 4'd2;
            12'b????????0111: FirstEmptyNote = 4'd3;
            12'b???????01111: FirstEmptyNote = 4'd4;
            12'b??????011111: FirstEmptyNote = 4'd5;
            12'b?????0111111: FirstEmptyNote = 4'd6;
            12'b????01111111: FirstEmptyNote = 4'd7;
            12'b???011111111: FirstEmptyNote = 4'd8;
            12'b??0111111111: FirstEmptyNote = 4'd9;
            12'b?01111111111: FirstEmptyNote = 4'd10;
            12'b011111111111: FirstEmptyNote = 4'd11;
            default:
            begin
                FirstEmptyNote = 'x;
                HasEmptyNoteSlot = '0;
            end
        endcase

        RegToExisting = (Present == FINISH);
    end

    always_comb // Association combinational
    begin
        CurrentlyAssociating = 'x;
        DoAssociatingWrite = '0;
        AssociatingWriteLoc = 'x;

        if(Present == ASSOC)
        begin
            // TODO: if more than 1 peak associates to a note, we'll overwrite previous peak info!
            if(~PeakHasAssociated[PeakCtr] && newPeaks[PeakCtr].valid && ExistingNotes[NoteCtr].valid) // we have a peak that fits here, and a note we can merge into
            begin
                CurrentlyAssociating.position = newPeaks[PeakCtr].position;
                CurrentlyAssociating.amplitude = newPeaks[PeakCtr].amplitude;
                CurrentlyAssociating.valid = '1;
                DoAssociatingWrite = AssociateHere;
                AssociatingWriteLoc = NoteCtr;
            end
        end
        else if(Present == NEWNOTES)
        begin
            if(~PeakHasAssociated[NoteCtr] && newPeaks[NoteCtr].valid && HasEmptyNoteSlot) // we have a peak that wants to make a new note, and a place to put it
            begin
                CurrentlyAssociating.position = newPeaks[NoteCtr].position;
                CurrentlyAssociating.amplitude = newPeaks[NoteCtr].amplitude;
                CurrentlyAssociating.valid = '1;
                DoAssociatingWrite = '1;
                AssociatingWriteLoc = FirstEmptyNote;
            end
        end
        else if(Present == DECAYNOTES)
        begin
            if(~NoteHasBeenAssociatedTo[NoteCtr] && ExistingNotes[NoteCtr].valid) // there is a valid note that has not been associated with
            begin
                CurrentlyAssociating.position = ExistingNotes[NoteCtr].position;
                CurrentlyAssociating.amplitude = ExistingNotes[NoteCtr].amplitude - ((ExistingNotes[NoteCtr].amplitude >> DECAYSHIFT) | 16'b1); // OR in a bit to make sure we always subtract at least 1
                CurrentlyAssociating.valid = ExistingNotes[NoteCtr].valid;
                if(ExistingNotes[NoteCtr].amplitude == '0) CurrentlyAssociating.valid = '0; // If the note has become too small (and would underflow)
                DoAssociatingWrite = '1;
                AssociatingWriteLoc = NoteCtr;
            end
        end
    end

    always_ff @(posedge clk, posedge rst) // Counters
    begin
        if(rst)
        begin
            PeakCtr <= '0;
            NoteCtr <= '0;
        end
        else if(Present == WAIT)
        begin
            PeakCtr <= '0;
            NoteCtr <= '0;
        end
        else if(Present == ASSOC || Present == NEWNOTES || Present == DECAYNOTES)
        begin
            if(NoteCtr == 11)
            begin
                NoteCtr <= '0;
                if(PeakCtr != 11) PeakCtr <= PeakCtr + 1'b1;
            end
            else NoteCtr <= NoteCtr + 1'b1;
        end
    end

    always_ff @(posedge clk, posedge rst) // Association registered
    begin
        if(rst)
        begin
            PeakHasAssociated <= '0;
            NoteHasBeenAssociatedTo <= '0;
        end
        else if(Present == WAIT)
        begin
            PeakHasAssociated <= '0;
            NoteHasBeenAssociatedTo <= '0;
            finished <= '0;
        end
        else if(Present == ASSOC && DoAssociatingWrite)
        begin
            PeakHasAssociated[PeakCtr] <= 1'b1;
            NoteHasBeenAssociatedTo[NoteCtr] <= 1'b1;
        end
        else if(Present == NEWNOTES && DoAssociatingWrite)
        begin
            PeakHasAssociated[NoteCtr] <= 1'b1; // These use different counters, not a bug
            NoteHasBeenAssociatedTo[FirstEmptyNote] <= 1'b1;
        end
        else if(Present == FINISH) finished <= '1;
    end

    // notes register
    // new notes
    // IIR between
    // exception if valid is rising, don't iir position

endmodule


// Checks if the middle bin is a local maximum, and is above a given threshold.
module PeakDetector
#(parameter N = 16)
(
    output logic isPeak,
    input logic [N-1:0] left, right, here, // the bins to the left and right, as well as this bin here
    input logic [N-1:0] threshold // how large the peak needs to be to be considered a peak, and not just noise
);
    logic localMax;
    assign localMax = (left < here) && (here > right);
    assign isPeak = localMax & (here > threshold);
endmodule

// Given 120 numbers of width N, outputs the highest among all of them.
module FindMax120 // TODO This is at the very least moderately hideous. Could probably make a recursive one that operates on 2^n sizes and assume the rest is synthesized away.
#(parameter N = 16)
(
    output logic unsigned [N-1:0] maxValue,
    input logic unsigned [N-1:0] values [0:119]
);
    logic unsigned [N-1:0] Level1 [0:59], Level2 [0:29], Level3 [0:14], Level4 [0:6], Level5 [0:2], Level6 [0:2], Level7;
    genvar i;
    generate
        for(i = 0; i < 60; i++)
        begin : CompL1
            assign Level1[i] = (values[i*2] > values[(i*2)+1]) ? values[i*2] : values[(i*2)+1];
        end

        for(i = 0; i < 30; i++)
        begin : CompL2
            assign Level2[i] = (Level1[i*2] > Level1[(i*2)+1]) ? Level1[i*2] : Level1[(i*2)+1];
        end

        for(i = 0; i < 15; i++)
        begin : CompL3
            assign Level3[i] = (Level2[i*2] > Level2[(i*2)+1]) ? Level2[i*2] : Level2[(i*2)+1];
        end

        for(i = 0; i < 7; i++) // 1 extra
        begin : CompL4
            assign Level4[i] = (Level3[i*2] > Level3[(i*2)+1]) ? Level3[i*2] : Level3[(i*2)+1];
        end

        for(i = 0; i < 3; i++)
        begin : CompL5
            assign Level5[i] = (Level4[i*2] > Level4[(i*2)+1]) ? Level4[i*2] : Level4[(i*2)+1];
        end // 1 extra
    endgenerate

    assign Level6[0] = (Level5[0] > Level5[1]) ? Level5[0] : Level5[1];
    assign Level6[1] = (Level5[2] > Level4[6]) ? Level5[2] : Level4[6];
    assign Level7 = (Level6[0] > Level6[1]) ? Level6[0] : Level6[1];
    assign maxValue = (Level7 > Level3[14]) ? Level7 : Level3[14];
endmodule

// Given 120 numbers of width N, outputs the highest among all of them. This one is a lot faster, jankier, and less precise.
// Inputting a worst-case peak of a 1 bit followed by all 0 bits, this could at maximum output that same starting 1 bit, followed by all ones, effectively doubling the peak value.
// Inputting a best casxe peak value of some number of 0 bits followed by contiguous 1 bits, this will output the precise peak
// Chances are that it'll usually be pretty close, since there is often more than 1 reasonably large peak, and as such most of the bits under the main peaks' leading 1 will be filled with 1s
// Therefore it's safe to assume the output is about 1.5-2.0x as large as the largest peak
module FindMax120Approx // TODO This is at the very least moderately hideous. Could probably make a recursive one that operates on 2^n sizes and assume the rest is synthesized away.
#(parameter N = 16)
(
    output logic unsigned [N-1:0] maxValue,
    input logic unsigned [N-1:0] values [0:119]
);
    assign maxValue = values[0] | values[1] | values[2] | values[3] | values[4] | values[5] | values[6] | values[7] | values[8] | values[9] | values[10] | values[11] | values[12] | values[13] | values[14] | values[15] |
        values[16] | values[17] | values[18] | values[19] | values[20] | values[21] | values[22] | values[23] | values[24] | values[25] | values[26] | values[27] | values[28] | values[29] | values[30] | values[31] |
        values[32] | values[33] | values[34] | values[35] | values[36] | values[37] | values[38] | values[39] | values[40] | values[41] | values[42] | values[43] | values[44] | values[45] | values[46] | values[47] |
        values[48] | values[49] | values[50] | values[51] | values[52] | values[53] | values[54] | values[55] | values[56] | values[57] | values[58] | values[59] | values[60] | values[61] | values[62] | values[63] |
        values[64] | values[65] | values[66] | values[67] | values[68] | values[69] | values[70] | values[71] | values[72] | values[73] | values[74] | values[75] | values[76] | values[77] | values[78] | values[79] |
        values[80] | values[81] | values[82] | values[83] | values[84] | values[85] | values[86] | values[87] | values[88] | values[89] | values[90] | values[91] | values[92] | values[93] | values[94] | values[95] |
        values[96] | values[97] | values[98] | values[99] | values[100] | values[101] | values[102] | values[103] | values[104] | values[105] | values[106] | values[107] | values[108] | values[109] | values[110] |
        values[111] | values[112] | values[113] | values[114] | values[115] | values[116] | values[117] | values[118] | values[119];
endmodule

// FPW must be at least $clog2(BPO).
// Increasing FPF above N does not yield better precision.
module PeakPlacer
#(parameter N = 16, parameter BPO = 24, parameter FPW = 5, parameter FPF = 10)
(
    output logic [(FPW+FPF)-1:0] peakPosition, // between 0 (inc) and BPO (exc)
    input logic [$clog2(BPO)-1:0] binIndex, // between 0 and BPO-1
    input logic [N-1:0] left, right, here
);
    logic [N-1:0] DiffL, DiffR, TotalAdjacentDiff;
    logic [(N*2)-1:0] PropDiffL, PropDiffR;
    logic [FPF-1:0] Fractional;
    
    always_comb
    begin
        DiffL = here - left;
        DiffR = here - right;
        TotalAdjacentDiff = DiffL + DiffR;
        PropDiffL = (DiffL << N) / TotalAdjacentDiff; // Bottom N bits are fractional part
        PropDiffR = (DiffR << N) / TotalAdjacentDiff;

        if(DiffL < DiffR) // More towards left
        begin
            Fractional = (1 << (FPF - 1)) + (PropDiffL >> (N - FPF));
            if(binIndex == 0) peakPosition = {(BPO - 1'd1), Fractional}; // Handles moving to the left of bin 0
            else peakPosition = {(binIndex - 1'd1), Fractional};
        end
        else // More towards right
        begin
            Fractional = (1 << (FPF - 1)) - (PropDiffR >> (N - FPF));
            peakPosition = {binIndex, Fractional};
        end
    end
endmodule


// Merges peaks from within the same folded bin using a weighted average. Cannot handle end wrap-around.
module PeakWAvg
#(parameter N = 16)
(
    output logic [N-1:0] peakAmp, peakPos, // amplitude and position of merged peak
    input logic [N-1:0] in0Amp, in0Pos, // amplitude and position of input peak 0
    input logic [N-1:0] in1Amp, in1Pos // amplitude and position of input peak 1
);
    logic [(N*2)-1:0] WeightedSum;

    always_comb
    begin
        peakAmp = in0Amp + in1Amp;
        WeightedSum = (in0Amp * in0Pos) + (in1Amp * in1Pos);
        peakPos = WeightedSum / peakAmp;
    end
endmodule

module PeakMergerItr
#(parameter N = 16)
(
    output logic [N-1:0] outPos, outAmp, // the averaged data to save to the register
    output logic outValid, // whether the register should be valid, only updated if writing
    output logic doRegWrite, // whether to write changes to the register
    input logic [N-1:0] peakPosition, peakAmp, // where and how strong the new potential peak is
    input logic isPeak, // whether this new data actually contains a peak
    input logic [N-1:0] regPos, regAmp, // the current data in the peak register for this slot
    input logic regValid // whether the peak register contains a valid peak for this slot
);
    logic [N-1:0] MergedPeakAmp, MergedPeakPos; // The results of a weighted average of new data, and existing data in the register
    PeakWAvg #(.N(N)) RegAvgr(.peakAmp(MergedPeakAmp), .peakPos(MergedPeakPos), .in0Amp(regAmp), .in0Pos(regPos), .in1Amp(peakAmp), .in1Pos(peakPosition));

    always_comb
    begin
        doRegWrite = isPeak;
        outValid = isPeak | regValid;

        if(isPeak && ~regValid) // we have a peak, and there isn't anything in the register yet
        begin
            outPos = peakPosition;
            outAmp = peakAmp;
        end
        else if(isPeak && regValid) // we have a peak, and there is existing data we need to merge with
        begin
            outPos = MergedPeakPos;
            outAmp = MergedPeakAmp;
        end
        else // we don't have a peak, do nothing
        begin
            outPos = 'x;
            outAmp = 'x;
        end
    end
endmodule


module PeakRegister
#(parameter N = 16)
(
    output logic [N-1:0] amp, pos,
    output logic hasPeak, // whether this location has a peak, and data is valid
    input logic [N-1:0] ampIn, posIn,
    input logic peakIn, // sets whether or not this is a valid peak
    input logic write,
    input logic clk, rst
);
    always_ff @(posedge clk)
        if(rst) hasPeak <= '0;
        else
        begin
            if(write)
            begin
                amp <= ampIn;
                pos <= posIn;
                hasPeak <= peakIn;
            end
        end
endmodule


module NoteRegister
(
    output Note out,
    input Note in,
    input logic write,
    input logic clk, rst
);
    always_ff @(posedge clk)
        if(rst) out.valid <= '0;
        else if(write)
        begin
            out.position <= in.position;
            out.amplitude <= in.amplitude;
            out.valid <= in.valid;
        end
endmodule


module NoteOperationManager
#(parameter OCT = 5)
(
    output logic [3:0] activeNoteSlot,
    output logic [$clog2(OCT)-1:0] activeOctave,
    output logic finished, doOperation, clearIntermediate,
    input logic start,
    input logic clk, rst
);
    typedef enum { WAIT, ACTIVE, FINISHED, XXX } NoteOpMgrState;
    NoteOpMgrState Present, Next;
    logic [1:0] WaitCounter;

    always_ff @(posedge clk) // State register
        if(rst) Present <= WAIT;
        else Present <= Next;
    
    always_ff @(posedge clk) // Timer register
        if(rst) WaitCounter <= '0;
        else if(Present == ACTIVE) WaitCounter <= WaitCounter + 1'b1;

    always_comb // Next state
    begin
        Next = XXX;
        case(Present)
            WAIT: if(start) Next = ACTIVE;
                  else Next = WAIT; // @LB
            ACTIVE: if(activeOctave == (OCT-1) && activeNoteSlot == (12-1) && doOperation) Next = FINISHED;
                    else Next = ACTIVE; // @LB
            FINISHED: Next = WAIT;
            default: Next = XXX;
        endcase
    end

    always_comb // Combinational outputs
    begin
        doOperation = WaitCounter[0] & WaitCounter[1] & (Present == ACTIVE); // True every 4th clock cycle while active
        finished = (Present == FINISHED);
        clearIntermediate = (Present == WAIT) && start;
    end

    always_ff @(posedge clk) // Registered outputs
    begin
        if(rst | finished)
        begin
            activeNoteSlot <= '0;
            activeOctave <= '0;
        end
        else if(doOperation)
        begin
            activeNoteSlot <= (activeNoteSlot == (12-1) ? '0 : activeNoteSlot + 1'b1);
            activeOctave <= ((activeNoteSlot == (12-1) && activeOctave != 4) ? activeOctave + 1'b1 : activeOctave);
        end
    end
endmodule