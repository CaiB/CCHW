$Peak1Start = 5.0;
$Peak2Start = 8.7;
$OutputFile = 'nfpeaks.txt';

$Length = 1024;
$Speed = 0.05;

Write-Host 'Calculating...';

$Peak1Pos = $Peak1Start;
$Peak2Pos = $Peak2Start;
$FileData = '';
for($Sample = 0; $Sample -LT $Length; $Sample++)
{
    if($Sample % 250 -EQ 0) { Write-Host "  At sample $Sample"; }
    for($Bin = 0.0; $Bin -LT 120; $Bin++)
    {
        $Value = [Math]::Max(0.0, 1.0 - [Math]::Min([Math]::Abs($Bin - $Peak1Pos), [Math]::Abs($Bin - $Peak2Pos))) * 32768;
        $ValueHex = '{0:X4}' -F [uint16][Math]::Round($Value);
        $FileData += "$ValueHex`n";
    }
    $Peak1Pos = ($Peak1Pos + $Speed) % 120.0;
    $Peak2Pos = ($Peak2Pos + $Speed) % 120.0;
}

Write-Host 'Outputting to file...';
if(Test-Path $OutputFile) { Remove-Item $OutputFile; }
New-Item -ItemType 'File' -Path $OutputFile -Value $FileData | Out-Null;

Write-Host 'Done!';