// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
module Test_DFT;
    localparam BINCOUNT = 120;
    localparam LEN = 1080;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(512)) DFTDUT(.outBins, .inputSample, .sampleReady, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = { 32'd53393227, 32'd55080784, 32'd56794035, 32'd58528097, 32'd60277242, 32'd62034816, 32'd63793162, 32'd65543532, 32'd67276015, 32'd68979448, 32'd70641352, 32'd72247858, 32'd73783655, 32'd75231946, 32'd76574423, 32'd77791267, 32'd78861173, 32'd79761416, 32'd80467952, 32'd80955574, 32'd81198120, 32'd81168752, 32'd80840307, 32'd80185732, 32'd79178614, 32'd77793803, 32'd76008143, 32'd73801316, 32'd71156790, 32'd68062876, 32'd64513882, 32'd60511357, 32'd56065398, 32'd51196006, 32'd45934469, 32'd40324781, 32'd34425184, 32'd28310168, 32'd22074241, 32'd15842875, 32'd9821696, 32'd4692668, 32'd4483347, 32'd8796414, 32'd13250706, 32'd17118935, 32'd20174569, 32'd22277318, 32'd23329743, 32'd23275162, 32'd22104373, 32'd19866192, 32'd16683980, 32'd12793418, 32'd8682524, 32'd5767256, 32'd6816055, 32'd10471310, 32'd14224872, 32'd17106242, 32'd18586212, 32'd18295088, 32'd16017480, 32'd11851944, 32'd7337468, 32'd9808688, 32'd19508837, 32'd31656628, 32'd44703270, 32'd57535411, 32'd68984941, 32'd77810996, 32'd82789702, 32'd82867542, 32'd77362884, 32'd66190453, 32'd50065738, 32'd30639309, 32'd10711627, 32'd9198710, 32'd21713076, 32'd27027155, 32'd23845867, 32'd13357489, 32'd3420224, 32'd15717307, 32'd23085768, 32'd20576849, 32'd8138512, 32'd10689137, 32'd26031810, 32'd29022347, 32'd12925265, 32'd22019214, 32'd65840693, 32'd102558963, 32'd116036393, 32'd98762604, 32'd57375719, 32'd10827718, 32'd19615451, 32'd23098947, 32'd6461547, 32'd11300317, 32'd14137994, 32'd2165866, 32'd9928249, 32'd8844212, 32'd2602674, 32'd9240950, 32'd2859051, 32'd6751544, 32'd5475820, 32'd4049621, 32'd6139718, 32'd2300959, 32'd5915259, 32'd1706493, 32'd5370817, 32'd2105627 };

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
            $display("Sample %4d finished", i);
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