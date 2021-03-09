$CosFile = 'costable.txt';
$SinFile = 'sintable.txt';
$StartFreq = 880;
$SampleRate = 48000;
$BinCount = 24;
$MagMultiplier = 1024;
$TopOctaveLen = 8192;
$Octaves = 5;

if(Test-Path $CosFile) { Remove-Item $CosFile; }
if(Test-Path $SinFile) { Remove-Item $SinFile; }

$CosContents = "";
$SinContents = "";
$SampleCounts = "";

Write-Host ("Generating sin & cos tables with {0} bins, starting at {1}Hz, for sample rate {2}Hz, amplitude {3}." -F $BinCount, $StartFreq, $SampleRate, $MagMultiplier);

$BinBitCount = [Math]::Ceiling([Math]::Log($SampleRate / $StartFreq, 2));
Write-Host "Address size of waves in table will be $BinBitCount.";

$WaveLengths = [double[]]::new($BinCount);

for($Bin = 0; $Bin -LT $BinCount; $Bin++)
{
    $Freq = $StartFreq * [Math]::Pow(2, $Bin / $BinCount);
    $WaveLen = [Math]::Ceiling($SampleRate / $Freq);
    $WaveLengths[$Bin] = $WaveLen;
    $SampleCounts += ("$BinBitCount'd{0}, " -F $WaveLen);
    Write-Host ("Freq at bin $Bin is {0:F3} Hz" -F [double]$Freq);

    for($Sample = 0; $Sample -LT 64; $Sample++) # This assumes all waves fit in 64 length.
    {
        $Cos = '{0:X4}' -F [int16][Math]::Round([Math]::Cos($Freq / $SampleRate * $Sample * 2 * [Math]::PI) * $MagMultiplier);
        $Sin = '{0:X4}' -F [int16][Math]::Round([Math]::Sin($Freq / $SampleRate * $Sample * 2 * [Math]::PI) * $MagMultiplier);
        $CosContents += "$Cos`n";
        $SinContents += "$Sin`n";
    }
}

$SampleCounts = $SampleCounts.Substring(0, $SampleCounts.Length - 2); # Remove trailing comma

Write-Host "Sample Counts: '{$SampleCounts}";

New-Item -ItemType 'File' -Path $CosFile -Value $CosContents | Out-Null; # Outputs directory listing, so piping to null.
New-Item -ItemType 'File' -Path $SinFile -Value $SinContents | Out-Null;

Write-Host "Generating subtract start positions assuming top octave is $TopOctaveLen samples long, and there are $Octaves octaves.";

for($Octave = 0; $Octave -LT $Octaves; $Octave++)
{
    $SubStarts = "";
    for($Bin = 0; $Bin -LT $BinCount; $Bin++)
    {
        $Pos = $WaveLengths[$Bin] - (($TopOctaveLen - 1) % $WaveLengths[$Bin]);
        $SubStarts += ("{0}'d{1}, " -F $BinBitCount, $Pos);
    }
    $SubStarts = $SubStarts.Substring(0, $SubStarts.Length - 2);
    $CondVal = $(if ($Octave -EQ 0) {'if'} else {'else if'});
    Write-Host "$CondVal(OCT == $Octave) DefaultValues = '{$SubStarts};";
    $TopOctaveLen /= 2;
}

Write-Host 'Done!';