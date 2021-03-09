// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
`timescale 1 ps / 1 ps
module Test_DFT;
    localparam BINCOUNT = 120;
    localparam LEN = 8250;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(8192)) DFTDUT(.outBins, .inputSample, .sampleReady, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = { 32'd20931412, 32'd56999887, 32'd55424414, 32'd11078850, 32'd56942860, 32'd78569397, 32'd27374380, 32'd67098198, 32'd106059404, 32'd28690225, 32'd113012428, 32'd144813498, 32'd33429485, 32'd253047247, 32'd157852357, 32'd425560888, 32'd1125472493, 32'd1272608589, 32'd657353334, 32'd104666704, 32'd272138104, 32'd52873315, 32'd167293731, 32'd61023788, 32'd108422792, 32'd82587801, 32'd53224204, 32'd94049693, 32'd34827150, 32'd65761744, 32'd82514865, 32'd41472160, 32'd52696328, 32'd99712213, 32'd102494562, 32'd51513184, 32'd74961903, 32'd264985672, 32'd876509217, 32'd1051521541, 32'd236993549, 32'd86005295, 32'd31896830, 32'd19310006, 32'd19967136, 32'd18842615, 32'd16735612, 32'd18218682, 32'd25183412, 32'd33886465, 32'd39235875, 32'd36335966, 32'd23196656, 32'd12989859, 32'd24990223, 32'd24345811, 32'd11323379, 32'd21134512, 32'd14517700, 32'd15874834, 32'd13770258, 32'd15167278, 32'd8902772, 32'd17036073, 32'd13668158, 32'd4102848, 32'd10758299, 32'd21100273, 32'd31613188, 32'd44821338, 32'd63496021, 32'd88867466, 32'd1304817873, 32'd130932734, 32'd105266797, 32'd28803732, 32'd46308910, 32'd29668874, 32'd37266888, 32'd2681887, 32'd26215590, 32'd30243570, 32'd26029094, 32'd22869847, 32'd22816534, 32'd22650896, 32'd14993784, 32'd5398690, 32'd19254756, 32'd2408927, 32'd15841762, 32'd15290928, 32'd9745410, 32'd7392455, 32'd9506826, 32'd13479714, 32'd10682408, 32'd5989848, 32'd9985755, 32'd11562756, 32'd8060598, 32'd7153942, 32'd9484457, 32'd9877584, 32'd1846846, 32'd9109613, 32'd8663909, 32'd7175799, 32'd8180176, 32'd7724435, 32'd2726743, 32'd5962832, 32'd7570301, 32'd7101309, 32'd3452422, 32'd5806391, 32'd1173516, 32'd2719608, 32'd1013256, 32'd5740300 };

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

    task InsertData(int samples);
        for(int i = 0; i < samples; i++)
        begin
            sampleReady = '1;
            inputSample = InputData[i];
            @(posedge clk);
            sampleReady = '0;
            repeat(250) @(posedge clk);
            if(i < 20 || i % 10 == 0) $display("Sample %4d finished", i);
        end
    endtask

    task CheckOutputs;
        $display("Raw Data:");
        for(int i = 0; i < 120; i++) $display("%d,%d", ExpectedOutputs[i], outBins[i]);

        $display("Comparisons:");
        for(int i = 0; i < 120; i++)
        begin
            real min, max;
            min = real'(ExpectedOutputs[i]) * 0.9;
            max = real'(ExpectedOutputs[i]) * 1.1;
            assert(outBins[i] > min) else $display("Bin %d had too low value %d, expected %d.", i, outBins[i], ExpectedOutputs[i]);
            assert(outBins[i] < max) else $display("Bin %d had too high value %d, expected %d.", i, outBins[i], ExpectedOutputs[i]);
        end
    endtask

    initial
    begin
        Reset();
        InsertData(LEN);
        CheckOutputs();
        $stop;
    end
endmodule