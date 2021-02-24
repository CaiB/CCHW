$CosFile = 'costable.txt';
$SinFile = 'sintable.txt';
$StartFreq = 880;
$SampleRate = 48000;
$BinCount = 24;
$MagMultiplier = 1024;

if(Test-Path $CosFile) { Remove-Item $CosFile; }
if(Test-Path $SinFile) { Remove-Item $SinFile; }

$CosContents = "";
$SinContents = "";
$SampleCounts = "";

Write-Host ("Generating sin & cos tables with {0} bins, starting at {1}Hz, for sample rate {2}Hz, amplitude {3}." -F $BinCount, $StartFreq, $SampleRate, $MagMultiplier);

$BinBitCount = [Math]::Ceiling([Math]::Log($SampleRate / $StartFreq, 2));
Write-Host "Address size of waves in table will be $BinBitCount.";

for($Bin = 0; $Bin -LT $BinCount; $Bin++)
{
    $Freq = $StartFreq * [Math]::Pow(2, $Bin / $BinCount);
    $SampleCounts += ("$BinBitCount'd{0}, " -F [Math]::Ceiling($SampleRate / $Freq));
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

Write-Host "Sample Counts: {$SampleCounts}";

New-Item -ItemType 'File' -Path $CosFile -Value $CosContents | Out-Null; # Outputs directory listing, so piping to null.
New-Item -ItemType 'File' -Path $SinFile -Value $SinContents | Out-Null;

Write-Host 'Done!';