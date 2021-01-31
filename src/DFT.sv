module WaveMultiplier
(
    output logic [31:0] outMagnitude,
    input logic signed [15:0] inSample,
    input logic signed [15:0] sinValue,
    input logic signed [15:0] cosValue,
    input logic clk, rst // TODO remove rst?
);
    logic signed [31:0] ProductSin, ProductCos;
    logic [31:0] absSin, absCos;

    always_comb begin
        // Calculate products
        ProductSin = inSample * sinValue;
        ProductCos = inSample * cosValue;

        // Find absolute value of products
        absSin = ProductSin[31] ? -ProductSin : ProductSin;
        absCos = ProductCos[31] ? -ProductCos : ProductCos;

        // Calculate magnitude
        if(absCos > absSin) outMagnitude = absCos + (absSin >> 1);
        else outMagnitude = absSin + (absCos >> 1);
    end
endmodule

module Test_WaveMultiplier();
    logic clk, rst, enableIncr;
    logic signed [31:0] outMagnitude;
    logic signed [15:0] in;
    logic signed [15:0] sinValue;
    logic signed [15:0] cosValue;
    logic [4:0] bin;

    WaveMultiplier DUT(.outMagnitude, .inSample(in), .sinValue, .cosValue, .clk, .rst);
    SinTables SinTable(.value(sinValue), .bin, .enableIncr, .clk, .rst);
    CosTables CosTable(.value(cosValue), .bin, .enableIncr, .clk, .rst);

    localparam DELAY = 200;

    always
    begin
        clk <= 0; #(DELAY / 2);
        clk <= 1; #(DELAY / 2);
    end

    initial // TODO: Rewrite this
    begin
        bin <= 0;
        enableIncr <= 0;
        rst <= 1;
        #DELAY;
        rst <= 0;
        #(DELAY / 2);
        in <= 16'h0000;
        #DELAY;
        in <= 16'h0010;
        #DELAY;
        in <= 16'h0020;
        #DELAY;
        in <= 16'h0030;
        #DELAY;
        in <= 16'h0040;
        #DELAY;
        enableIncr <= 1;
        in <= 16'h0050;
        #DELAY;
        enableIncr <= 0;
        in <= 16'h0040;
        #DELAY;
        in <= 16'h0030;
        #DELAY;
        in <= 16'hFFC0;
        #DELAY;
        in <= 16'hFFB0;
        #DELAY;
        $stop;
    end
endmodule

module SampleStorage
(
    output logic [15:0] firstSample, lastSample,
    input logic [15:0] newSample,
    input logic clk
);
    localparam TOPSIZE = 8192;

    logic [TOPSIZE:0][15:0] Inter;

    SampleRegister TopOctaveReg0(.out(Inter[1]), .in(newSample), .clk);
    genvar i;
    generate
        for(i = 1; i < TOPSIZE; i++)// MakeTopOctStorage
        begin
            SampleRegister TopOctaveReg(.out(Inter[i+1]), .in(Inter[i]), .clk);
        end
    endgenerate

    always_comb
    begin
        assign lastSample = Inter[TOPSIZE];
        assign firstSample = Inter[1];
    end

endmodule

module Test_SampleStorage();
    logic clk;
    logic [15:0] in, outFirst, outLast;

    SampleStorage DUT(.firstSample(outFirst), .lastSample(outLast), .newSample(in), .clk);

    localparam DELAY = 200;

    always
    begin
        clk <= 0; #(DELAY / 2);
        clk <= 1; #(DELAY / 2);
    end

    initial
    begin
        in <= 16'h0000; #10;
        
        @(negedge clk); #10;
        in <= 16'hAAAA;
        assert(outFirst == 16'h0000);

        @(negedge clk); #10;
        in <= 16'hFFFF;
        assert(outFirst == 16'hAAAA);
        assert(DUT.Inter[2] == 16'h0000);

        @(negedge clk); #10;
        in <= 16'h0001;
        assert(outFirst == 16'hFFFF);
        assert(DUT.Inter[2] == 16'hAAAA);
        assert(DUT.Inter[3] == 16'h0000);

        @(negedge clk); #10;
        in <= 16'h0000;
        assert(outFirst == 16'h0001);
        
        @(negedge clk); #10;
        in <= 16'hAAAA;
        assert(outFirst == 16'h0000);
        
        @(negedge clk); #10;
        in <= 16'hFFFF;
        assert(outFirst == 16'hAAAA);
        
        @(negedge clk); #10;
        in <= 16'h0001;
        assert(outFirst == 16'hFFFF);

        $stop;
    end
endmodule

module SampleRegister
(
    output logic [15:0] out,
    input wire [15:0] in,
    input wire clk
);
    always_ff @(posedge clk) out <= in;
endmodule

module Test_SampleRegister();
    logic clk;
    logic [15:0] out, in;

    SampleRegister DUT(.out, .in, .clk);

    always
    begin
        clk <= 0; #100;
        clk <= 1; #100;
    end

    initial
    begin
        in <= 16'h0000;
        @(posedge clk); #10;
        assert(out == 16'h0000);

        @(posedge clk); #10;
        assert(out == 16'h0000);

        @(negedge clk);
        in <= 16'hAAAA;
        assert(out == 16'h0000);

        @(posedge clk); #10;
        assert(out == 16'hAAAA);

        @(posedge clk);
        assert(out == 16'hAAAA);

        #20;
        in <= 16'hFFFF; #10;
        assert(out == 16'hAAAA);
        @(negedge clk); #10;
        assert(out == 16'hAAAA);
        in <= 16'h0001;

        @(posedge clk); #10;
        assert(out == 16'h0001);
        $stop;
    end
endmodule