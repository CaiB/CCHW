$DataFile = 'dfttestdata.txt';
$TestFile = '../src/Test_DFTWithData.sv';

# Waves are defined as (Freqency [Hz], Amplitude [0~1], Phase [deg]).
$Wave1 = @(167.54, 0.3, 0);
$Wave2 = @(440, 0.3, 90);
#$Wave2 = @(0, 0, 0);
$Wave3 = @(89, 0.3, 127);
#$Wave3 = @(0, 0, 0);

$SampleRate = 48000;

# What a peak at amplitude 1 should correspond to in the data
$MagMultiplier = 1024;

# How many samples long the data should be.
$Length = 8250;

# How closely the output is expected to match the theoretical output. +/-15% error bounds is 0.15.
$TestErrorBounds = 0.1;

# Data cuts off and becomes all 0s after this sample index. Set to 0 for no cutoff.
$Cutout = 0;

$DataContents = "";
$WaveData = [double[]]::new($Length);
Write-Host "Generating test wave data into '$DataFile'...";

for($Sample = 0; $Sample -LT $Length; $Sample++)
{
    $Sample1 = [Math]::Sin($Wave1[0] / $SampleRate * $Sample * 2 * [Math]::PI + ($Wave1[2] / 180 * [Math]::PI)) * $MagMultiplier * $Wave1[1];
    $Sample2 = [Math]::Sin($Wave2[0] / $SampleRate * $Sample * 2 * [Math]::PI + ($Wave2[2] / 180 * [Math]::PI)) * $MagMultiplier * $Wave2[1];
    $Sample3 = [Math]::Sin($Wave3[0] / $SampleRate * $Sample * 2 * [Math]::PI + ($Wave3[2] / 180 * [Math]::PI)) * $MagMultiplier * $Wave3[1];
    $SampleValuePre = $Sample1 + $Sample2 + $Sample3;
    if(($Cutout -NE 0) -AND ($Sample -GE $Cutout)) { $SampleValuePre = 0; }
    [int16]$SampleValue = [int16][Math]::Round($SampleValuePre);
    $DataContents += "{0:X4}`n" -F $SampleValue;
    $WaveData[$Sample] = $SampleValuePre;
}

if(Test-Path $DataFile) { Remove-Item $DataFile; }
New-Item -ItemType 'File' -Path $DataFile -Value $DataContents | Out-Null; # Outputs directory listing, so piping to null.


# This is just a simplified version of the DFT... should produce similar enough outputs.
Write-Host 'Calculating expected values...';
$ExpectedValues = "";

$StartFreq = 55;
$BinCount = 24;
$OctaveCount = 5;
$MagTrig = 1024; # Should match what's in the tables from GenerateTables.ps1

$TotalBinCount = $BinCount * $OctaveCount;
for($Bin = 0; $Bin -LT $TotalBinCount; $Bin++)
{
    $Freq = $StartFreq * [Math]::Pow(2, $Bin / $BinCount);
    $SinSum = 0.0;
    $CosSum = 0.0;
    for($Sample = 0; $Sample -LT $Length; $Sample++)
    {
        $Sin = [Math]::Sin($Freq / $SampleRate * $Sample * 2 * [Math]::PI);
        $Cos = [Math]::Cos($Freq / $SampleRate * $Sample * 2 * [Math]::PI);
        $SinSum += $Sin * $WaveData[$Sample];
        $CosSum += $Cos * $WaveData[$Sample];
    }
    # Proper square root
    $Magnitude = [Math]::Sqrt($SinSum * $SinSum + $CosSum * $CosSum);
    
    # Approximate norm
    #$SinSum = [Math]::Abs($SinSum);
    #$CosSum = [Math]::Abs($CosSum);
    #if($SinSum -GT $CosSum) { $Magnitude = $SinSum + ($CosSum -SHR 1); }
    #else { $Magnitude = $CosSum + ($SinSum -SHR 1); }

    $Magnitude *= $MagTrig;
    Write-Host "$Magnitude";
    $MagRound = [int32][Math]::Round($Magnitude);
    $ExpectedValues += ("32'd{0}, " -F $MagRound);
}
$ExpectedValues = $ExpectedValues.Substring(0, $ExpectedValues.Length - 2); # Remove trailing comma

Write-Host "Generating testbench code into '$TestFile'...";
$LowerBound = 1.0 - $TestErrorBounds;
$UpperBound = 1.0 + $TestErrorBounds;
$TestBenchContents = 
@"
// WARNING: THIS FILE WILL BE OVERWRITTEN BY A SCRIPT. SAVE ANY CHANGES ELSEWHERE!
``timescale 1 ps / 1 ps
module Test_DFT;
    localparam BINCOUNT = $TotalBinCount;
    localparam LEN = $Length;

    logic unsigned [35:0] outBins [0:BINCOUNT-1];
    logic signed [15:0] inputSample;
    logic sampleReady;
    logic clk, rst;

    DFT #(.BPO(24), .OC(5), .N(16), .TOPSIZE(8192)) DFTDUT(.outBins, .inputSample, .sampleReady, .clk, .rst);

    logic signed [15:0] InputData [0:LEN-1];
    initial `$readmemh("../other/dfttestdata.txt", InputData);
    logic unsigned [31:0] ExpectedOutputs [0:BINCOUNT-1];
    assign ExpectedOutputs = { $ExpectedValues };

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
            if(i < 20 || i % 10 == 0) `$display("Sample %4d finished", i);
        end
    endtask

    task CheckOutputs;
        `$display("Raw Data:");
        for(int i = 0; i < $TotalBinCount; i++) `$display("%d,%d", ExpectedOutputs[i], outBins[i]);

        /*`$display("Comparisons:");
        for(int i = 0; i < $TotalBinCount; i++)
        begin
            real min, max;
            min = real'(ExpectedOutputs[i]) * $LowerBound;
            max = real'(ExpectedOutputs[i]) * $UpperBound;
            assert(outBins[i] > min) else `$display("Bin %d had too low value %d, expected %d.", i, outBins[i], ExpectedOutputs[i]);
            assert(outBins[i] < max) else `$display("Bin %d had too high value %d, expected %d.", i, outBins[i], ExpectedOutputs[i]);
        end*/
    endtask

    initial
    begin
        Reset();
        InsertData(LEN);
        CheckOutputs();
        `$stop;
    end
endmodule
"@;

if(Test-Path $TestFile) { Remove-Item $TestFile; }
New-Item -ItemType 'File' -Path $TestFile -Value $TestBenchContents | Out-Null;

Write-Host 'Done!';