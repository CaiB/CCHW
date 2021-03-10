// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
`timescale 1 ps / 1 ps
module Test_DFT;
    localparam BINCOUNT = 120;
    localparam LEN = 16500;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(8192)) DFTDUT(.outBins, .inputSample, .sampleReady, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = { 32'd36317450, 32'd23854289, 32'd7799202, 32'd29003004, 32'd37586992, 32'd23294038, 32'd10999786, 32'd34809730, 32'd35651237, 32'd10556408, 32'd28192696, 32'd40039718, 32'd16504161, 32'd26703459, 32'd41863477, 32'd13882871, 32'd33779915, 32'd40348810, 32'd8699716, 32'd46009274, 32'd24487957, 32'd36370271, 32'd42740359, 32'd22804494, 32'd53015067, 32'd13519983, 32'd59787251, 32'd12009188, 32'd66493322, 32'd21477260, 32'd71669266, 32'd49705418, 32'd63490001, 32'd99624367, 32'd12715337, 32'd150831953, 32'd151122234, 32'd87705056, 32'd848648074, 32'd929242887, 32'd35174428, 32'd117679509, 32'd123966846, 32'd81893471, 32'd35254762, 32'd8579780, 32'd21683547, 32'd28962677, 32'd29810478, 32'd27646566, 32'd24546249, 32'd21352641, 32'd18118874, 32'd14564963, 32'd10740756, 32'd8678445, 32'd11507710, 32'd15350708, 32'd14316134, 32'd6289706, 32'd12425288, 32'd19071998, 32'd5581187, 32'd20241376, 32'd16372508, 32'd22162541, 32'd19484975, 32'd37618576, 32'd1333052, 32'd55476116, 32'd92822363, 32'd100306194, 32'd1100167106, 32'd68960213, 32'd50409370, 32'd34200662, 32'd19147437, 32'd3793147, 32'd11653091, 32'd21074314, 32'd16282815, 32'd2999458, 32'd14207209, 32'd1666221, 32'd10386254, 32'd7311478, 32'd1763398, 32'd3985223, 32'd5569178, 32'd5882513, 32'd4655337, 32'd605272, 32'd10344498, 32'd17905356, 32'd3730395, 32'd40156512, 32'd60335845, 32'd1100508601, 32'd38350110, 32'd22237831, 32'd5099368, 32'd13688011, 32'd21594380, 32'd806069, 32'd15406164, 32'd12460384, 32'd8032433, 32'd7922257, 32'd10358622, 32'd7754746, 32'd5450465, 32'd4449935, 32'd7531602, 32'd7352749, 32'd5203866, 32'd1756648, 32'd6352104, 32'd4966548, 32'd3365197, 32'd4505819 };

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