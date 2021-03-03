// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
module Test_DFT;
    localparam BINCOUNT = 120;
    localparam LEN = 1080;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(1024)) DFTDUT(.outBins, .inputSample, .sampleReady, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial $readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = { 32'd42215279, 32'd49864214, 32'd57932760, 32'd66387850, 32'd75184071, 32'd84262103, 32'd93547207, 32'd102947816, 32'd112354347, 32'd121638313, 32'd130651893, 32'd139228090, 32'd147181654, 32'd154310961, 32'd160401018, 32'd165227798, 32'd168564068, 32'd170186848, 32'd169886558, 32'd167477862, 32'd162812044, 32'd155790637, 32'd146379791, 32'd134624681, 32'd120662945, 32'd104735946, 32'd87196357, 32'd68510437, 32'd49253361, 32'd30096739, 32'd11797563, 32'd5077028, 32'd19338742, 32'd30602414, 32'd38240129, 32'd41881136, 32'd41417773, 32'd37052143, 32'd29323499, 32'd19107431, 32'd7614999, 32'd4393624, 32'd14384719, 32'd21841708, 32'd25632942, 32'd25243386, 32'd20793111, 32'd13102447, 32'd3915628, 32'd6699146, 32'd14277765, 32'd18446378, 32'd18148933, 32'd13472434, 32'd5885596, 32'd4841431, 32'd11852942, 32'd15436454, 32'd13871573, 32'd7626883, 32'd4370532, 32'd12177434, 32'd16524972, 32'd13711401, 32'd4193027, 32'd12839231, 32'd25547494, 32'd27125459, 32'd9460540, 32'd30903929, 32'd86265082, 32'd139791637, 32'd168578419, 32'd155036402, 32'd99213213, 32'd24055988, 32'd33864007, 32'd46629329, 32'd16570534, 32'd22685593, 32'd32799006, 32'd6252118, 32'd24800944, 32'd22800093, 32'd9175515, 32'd27207637, 32'd4503581, 32'd25851509, 32'd13465302, 32'd24541598, 32'd19377662, 32'd27791996, 32'd24095685, 32'd43389941, 32'd28661957, 32'd130060857, 32'd230490465, 32'd114744225, 32'd33044432, 32'd19552121, 32'd25951943, 32'd7869221, 32'd9995611, 32'd13553721, 32'd7351803, 32'd3409531, 32'd7427246, 32'd7875136, 32'd5653291, 32'd3232759, 32'd2970597, 32'd3895589, 32'd4446248, 32'd4540660, 32'd4387031, 32'd4152726, 32'd3916680, 32'd3684280, 32'd3411210, 32'd3033965 };

    initial
    begin
        clk <= '0;
        forever #100 clk <= ~clk;
    end

    task Reset;
        rst = '1;
        inputSample = '0;
        sampleReady = '0;
        repeat(3) @(posedge clk);
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