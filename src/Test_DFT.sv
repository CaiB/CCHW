// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
`timescale 1 ps / 1 ps
module Test_DFT;
    localparam BINCOUNT = 120;
    localparam LEN = 10000;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(8192)) DFTDUT(.outBins, .inputSample, .sampleReady, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = { 32'd35225330, 32'd18585585, 32'd19543775, 32'd35790140, 32'd12261271, 32'd28438522, 32'd32000447, 32'd9805364, 32'd37674233, 32'd12383519, 32'd34126341, 32'd24231791, 32'd28782225, 32'd30429267, 32'd26615567, 32'd31937749, 32'd29894902, 32'd28158295, 32'd38357234, 32'd15693845, 32'd46752497, 32'd12998213, 32'd40885144, 32'd44642417, 32'd6359885, 32'd49420374, 32'd52662969, 32'd13753673, 32'd39459673, 32'd69957201, 32'd66454999, 32'd34457501, 32'd14348583, 32'd62510773, 32'd108170505, 32'd153210337, 32'd211623865, 32'd330914397, 32'd871294167, 32'd1111282611, 32'd328248045, 32'd184738886, 32'd114308873, 32'd61258585, 32'd14859518, 32'd26800049, 32'd46486668, 32'd37814946, 32'd8342953, 32'd26485195, 32'd22703339, 32'd12341278, 32'd20867531, 32'd11145697, 32'd15309507, 32'd16238042, 32'd6824736, 32'd13932928, 32'd18153942, 32'd15629767, 32'd10290520, 32'd5833205, 32'd4047158, 32'd4412715, 32'd10675893, 32'd25369855, 32'd44276228, 32'd47752439, 32'd5303437, 32'd132523309, 32'd166855690, 32'd343282355, 32'd10198500, 32'd59860533, 32'd54458946, 32'd36321674, 32'd25153314, 32'd22236062, 32'd23336943, 32'd21196667, 32'd7798189, 32'd12792948, 32'd11678242, 32'd12748865, 32'd2322911, 32'd7516814, 32'd9906465, 32'd9374629, 32'd5804768, 32'd5446996, 32'd13861756, 32'd3312637, 32'd16570089, 32'd21580278, 32'd25967103, 32'd42932194, 32'd83772340, 32'd1573608159, 32'd92754479, 32'd31020332, 32'd9226350, 32'd9536669, 32'd17230450, 32'd12666657, 32'd12027155, 32'd3864707, 32'd2791334, 32'd7050987, 32'd9000435, 32'd5739419, 32'd2045075, 32'd2762221, 32'd6736494, 32'd2383197, 32'd5303013, 32'd4603413, 32'd1591861, 32'd5142471, 32'd5169886, 32'd4671919 };

    integer FileHandle;

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end

    task Reset;
        rst = '1;
        inputSample = '0;
        sampleReady = '0;
        @(posedge clk);
        rst = '0;
        @(posedge clk);
    endtask

    string FileLine = "";
    task InsertData(int samples);
        for(int i = 0; i < samples; i++)
        begin
            sampleReady = '1;
            inputSample = InputData[i];
            @(posedge clk);
            sampleReady = '0;
            repeat(250) @(posedge clk);
            if(i < 20 || i % 10 == 0) $display("Sample %4d finished", i);

            for(int j = 0; j < BINCOUNT; j++) FileLine = $sformatf("%s%0d,", FileLine, outBins[j]);
            $fwrite(FileHandle, "%s\n", FileLine);
            FileLine = "";
        end
    endtask

    task CheckOutputs;
        $display("Raw Data:");
        for(int i = 0; i < 120; i++) $display("%d,%d", ExpectedOutputs[i], outBins[i]);

        /*$display("Comparisons:");
        for(int i = 0; i < 120; i++)
        begin
            real min, max;
            min = real'(ExpectedOutputs[i]) * 0.9;
            max = real'(ExpectedOutputs[i]) * 1.1;
            assert(outBins[i] > min) else $display("Bin %d had too low value %d, expected %d.", i, outBins[i], ExpectedOutputs[i]);
            assert(outBins[i] < max) else $display("Bin %d had too high value %d, expected %d.", i, outBins[i], ExpectedOutputs[i]);
        end*/
    endtask

    initial
    begin
        FileHandle = $fopen("dftoutput.csv", "w");

        Reset();
        InsertData(LEN);
        CheckOutputs();

        $fclose(FileHandle);
        $stop;
    end
endmodule