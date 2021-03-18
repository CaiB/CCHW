// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
`timescale 1 ps / 1 ps
module Test_DFT;
    localparam BINCOUNT = 120;
    localparam LEN = 10000;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic doingRead;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(8192)) DFTDUT(.outBins, .inputSample, .doingRead, .sampleReady, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = '{ 32'd34001803, 32'd18188870, 32'd18662026, 32'd34598721, 32'd12128752, 32'd27290737, 32'd31085663, 32'd9257032, 32'd36404981, 32'd12293725, 32'd32846228, 32'd23737092, 32'd27604187, 32'd29719434, 32'd25481927, 32'd31213016, 32'd28680580, 32'd27639874, 32'd36990135, 32'd15643217, 32'd45383479, 32'd12193457, 32'd40057637, 32'd43191901, 32'd6366210, 32'd48451870, 32'd51144648, 32'd12869162, 32'd39071935, 32'd68629075, 32'd64859188, 32'd33227114, 32'd14638566, 32'd62175852, 32'd107230912, 32'd151863382, 32'd210043957, 32'd329217752, 32'd869545376, 32'd1113042464, 32'd329961901, 32'd186288582, 32'd115475867, 32'd61715325, 32'd14128260, 32'd28037377, 32'd48350485, 32'd39046846, 32'd7300504, 32'd28015428, 32'd23764452, 32'd12294382, 32'd22241579, 32'd10352392, 32'd16400956, 32'd15715940, 32'd5978472, 32'd14280326, 32'd16345427, 32'd12646114, 32'd7787634, 32'd4782430, 32'd3982927, 32'd3878963, 32'd7701019, 32'd17990972, 32'd31082758, 32'd33137368, 32'd3962645, 32'd89415061, 32'd111595677, 32'd228081310, 32'd6835711, 32'd39613946, 32'd36017819, 32'd24065987, 32'd16740984, 32'd14947156, 32'd16016947, 32'd15157918, 32'd6479687, 32'd9247481, 32'd10068827, 32'd10140898, 32'd2600225, 32'd8570216, 32'd11303751, 32'd11542744, 32'd8082177, 32'd4962608, 32'd18258134, 32'd2896580, 32'd23103777, 32'd29970522, 32'd36034312, 32'd59064780, 32'd113249317, 32'd2097388874, 32'd121636156, 32'd39168227, 32'd10509902, 32'd10747461, 32'd20485223, 32'd15816466, 32'd13582921, 32'd3444713, 32'd2316872, 32'd7198972, 32'd10323167, 32'd5589852, 32'd1826901, 32'd2323987, 32'd6842232, 32'd3108252, 32'd5922201, 32'd5201484, 32'd1582239, 32'd5414150, 32'd5111387, 32'd4846989 };

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
        repeat(500) @(posedge clk);
        @(negedge clk);
        rst = '0;
        repeat(5) @(posedge clk);
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
            if(i < 20 || i % 500 == 0) $display("Sample %4d finished", i);
            if(i == 20) $display("[INFO] Slowing console output to once every 500 samples.");

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