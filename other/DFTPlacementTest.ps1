$DataFile = 'dftbincorrelation.csv';

$SampleRate = 48000;

# How many samples long the data should be.
$Length = 8192;

$MinTest = 1440;
$MaxTest = 1520;
$TestStep = 1;
$CurrentTest = $MinTest;

$StartFreq = 55;
$BinCount = 24;
$OctaveCount = 5;
$TotalBinCount = $BinCount * $OctaveCount;

if(Test-Path $DataFile) { Remove-Item $DataFile; }

$Freqs = [double[]]::new($TotalBinCount);
for($FreqInd = 0; $FreqInd -LT $TotalBinCount; $FreqInd++) { $Freqs[$FreqInd] = $StartFreq * [Math]::Pow(2, $FreqInd / $BinCount); }

$Header = "Input Signal Freq,";
for($FreqInd = 0; $FreqInd -LT $TotalBinCount; $FreqInd++) { $Header += "{0}," -F $Freqs[$FreqInd]; }

$FileContents = "$Header`n";

while($CurrentTest -LT $MaxTest)
{
    Write-Host "Calculating for $CurrentTest Hz...";
    $FileLine = "{0}," -F $CurrentTest;

    $Wave = [double[]]::new($Length);
    for($Sample = 0; $Sample -LT $Length; $Sample++) { $Wave[$Sample] = [Math]::Sin($CurrentTest / $SampleRate * $Sample * 2 * [Math]::PI); }

    for($Bin = 0; $Bin -LT $TotalBinCount; $Bin++)
    {
        $SinSum = 0.0;
        $CosSum = 0.0;
        for($Sample = 0; $Sample -LT $Length; $Sample++)
        {
            $Sin = [Math]::Sin($Freqs[$Bin] / $SampleRate * $Sample * 2 * [Math]::PI);
            $Cos = [Math]::Cos($Freqs[$Bin] / $SampleRate * $Sample * 2 * [Math]::PI);
            $SinSum += $Sin * $Wave[$Sample];
            $CosSum += $Cos * $Wave[$Sample];
        }
        $Magnitude = [Math]::Round([Math]::Sqrt($SinSum * $SinSum + $CosSum * $CosSum));
        $FileLine += "{0}," -F $Magnitude;
    }
    $FileContents += "$FileLine`n"
    $CurrentTest += $TestStep;
}

New-Item -ItemType 'File' -Path $DataFile -Value $FileContents | Out-Null;

Write-Host 'Done!';