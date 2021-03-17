[double] $IIRConst = 0.99;
[int] $SampleRate = 48000;
[double] $TargetValue = 0.9999;

Write-Host "Using IIR const $IIRConst and sample rate $SampleRate Hz";

[double] $NewVal = 1.0;
[double] $OutputVal = 0.0;
[int] $CyclesTaken = 0;
while($OutputVal -LE $TargetValue)
{
    $OutputVal = ($IIRConst * $OutputVal) + ((1.0 - $IIRConst) * $NewVal);
    $CyclesTaken++;
}

$TimeTaken = $CyclesTaken * 1000.0 / $SampleRate;
Write-Host "It took $CyclesTaken samples ($TimeTaken ms) to get to the target value.";