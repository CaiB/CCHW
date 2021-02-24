// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
module Test_DFT;
    localparam BINCOUNT = 120;
    localparam LEN = 1024;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic readSample;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16)) DFTDUT(.outBins, .inputSample, .readSample, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = { 32'd2788405, 32'd2962666, 32'd3132193, 32'd3289318, 32'd3426654, 32'd3537156, 32'd3614235, 32'd3651919, 32'd3645114, 32'd3589963, 32'd3484354, 32'd3328649, 32'd3126734, 32'd2887629, 32'd2627924, 32'd2375178, 32'd2170874, 32'd2066664, 32'd2103795, 32'd2284312, 32'd2568601, 32'd2900403, 32'd3226546, 32'd3502441, 32'd3691899, 32'd3766877, 32'd3708645, 32'd3510707, 32'd3184236, 32'd2768320, 32'd2349576, 32'd2084756, 32'd2144796, 32'd2525132, 32'd3047098, 32'd3532166, 32'd3853739, 32'd3929109, 32'd3718661, 32'd3239842, 32'd2605748, 32'd2116651, 32'd2224385, 32'd2886342, 32'd3624868, 32'd4094048, 32'd4106018, 32'd3609183, 32'd2749107, 32'd2099096, 32'd2542375, 32'd3587724, 32'd4338380, 32'd4359831, 32'd3563336, 32'd2381405, 32'd2377315, 32'd3739732, 32'd4726991, 32'd4550224, 32'd3200967, 32'd2170443, 32'd3683698, 32'd5120850, 32'd4873259, 32'd2982919, 32'd2678054, 32'd5028321, 32'd5718610, 32'd3761687, 32'd2637853, 32'd5633899, 32'd6235066, 32'd3287406, 32'd4101396, 32'd7218702, 32'd5410162, 32'd3074536, 32'd7839977, 32'd6796032, 32'd3183761, 32'd9270131, 32'd7087885, 32'd5278473, 32'd11667982, 32'd4719364, 32'd11472528, 32'd11854968, 32'd8069773, 32'd18475217, 32'd4542188, 32'd26081362, 32'd5839892, 32'd41907969, 32'd10331085, 32'd123053315, 32'd209186946, 32'd174059598, 32'd157944739, 32'd77163583, 32'd32775844, 32'd16742553, 32'd28783946, 32'd7928680, 32'd16566384, 32'd21296367, 32'd6698033, 32'd17994237, 32'd35148836, 32'd39155805, 32'd153643455, 32'd43915137, 32'd29881150, 32'd19652799, 32'd12316139, 32'd7595987, 32'd4970603, 32'd3765400, 32'd3335845, 32'd3356190 };

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end

    task Reset;
        rst = '1;
        inputSample = '0;
        readSample = '0;
        @(posedge clk);
        rst = '0;
        @(posedge clk);
    endtask

    task InsertData(int samples);
        for(int i = 0; i < samples; i++)
        begin
            readSample = '1;
            inputSample = InputData[i];
            @(posedge clk);
            readSample = '0;
            repeat(250) @(posedge clk);
            $display("Sample %4d finished", i);
        end
    endtask

    task CheckOutputs;
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