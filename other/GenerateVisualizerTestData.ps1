$Positions = @(0.483611822, 0.261237949, 0.843279064, 0.9416283, 0.7759455, 0.6389774, 0.3373046, 0.5607608, 0.03857844, -4.16666651, -4.16666651, 0)
$Amplitudes = @(0.586363, 0.700599, 0.439384162, 0, 0, 0, 0, 0, 0, 0, 0, 0)

$PositionsWhole = [int[]]::new(12)
$PositionsDecimal = [float[]]::new(12)
$AmplitudesWhole = [int[]]::new(12)
$AmplitudesDecimal = [float[]]::new(12)


# TODO: add parameters to this script
for ($i = 0; $i -lt 12; $i++) {
    $PositionsWhole[$i] = [Math]::Floor($Positions[$i])
    $PositionsDecimal[$i] = $Positions[$i] - $PositionsWhole[$i]

    $AmplitudesWhole[$i] = [Math]::Floor($Amplitudes[$i])
    $AmplitudesDecimal[$i] = $Amplitudes[$i] - $AmplitudesWhole[$i]
}

if (-not (Test-Path "$PSScriptRoot\testNotePositions.mem")) { New-Item -Path "$PSScriptRoot\testNotePositions.mem" -Value "" }
if (-not (Test-Path "$PSScriptRoot\testNoteAmplitudes.mem")) { New-Item -Path "$PSScriptRoot\testNoteAmplitudes.mem" -Value "" }

Set-Content "$PSScriptRoot\testNotePositions.mem" -Value ""
Set-Content "$PSScriptRoot\testNoteAmplitudes.mem" -Value ""

for ($i = 0; $i -lt 12; $i++) {
    $FPPosition = & py.exe $PSScriptRoot/fixedPointCalculator.py $PositionsDecimal[$i] 10
    $Positions[$i] = "000000" + $FPPosition.Split(",")[0]
    Add-Content -Path "$PSScriptRoot\testNotePositions.mem" -Value $Positions[$i]

    $FPAmplitude = & py.exe $PSScriptRoot/fixedPointCalculator.py $AmplitudesDecimal[$i] 10
    $Amplitudes[$i] = [String] -join ("000000", $FPAmplitude.Split(",")[0])
    Add-Content -Path "$PSScriptRoot\testNoteAmplitudes.mem" -Value $Amplitudes[$i]
}

