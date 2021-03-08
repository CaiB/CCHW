[String] $ModuleName = $args[0]

[String] $ScriptDirectory = $PSScriptRoot
[String] $FilePath = "$ScriptDirectory\..\sim"

[String] $content = @'
# Create work library
vlib work

# Source and Testbench files
vlog -work work "../src/{0}.sv"

# Call simulator
vsim -voptargs="+acc" -t 1ps -lib work {0}_testbench

# Source the wave file
do Test_{0}_wave.do

# Set windows
view wave
view structure
view signals

# Run the simulation
run -all

# End
'@ -f $ModuleName

#Write-Host "Writing to $file_path\Test_$module_name.do"
#Write-Host $content

New-Item -Path "$FilePath\Test_$ModuleName.do" -Value $Content