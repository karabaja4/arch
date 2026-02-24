function Log ($message) {
    $timestamped = "[$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')] $message"
    Write-Host $timestamped
    $timestamped | Out-File -FilePath $logFile -Append
}

$logFile = "C:\tools\rwe\fixnet.log"
$rwExe = "C:\tools\rwe\Rw.exe"
$pciAddr = "0x81 0x00 0x00 0xB0"

& $rwExe /Min /Nologo /Stdout /Command="RPCI $pciAddr" | Tee-Object -Variable tempOutput | Out-Null
Log "Read output: $tempOutput"

$value = ($tempOutput -split '=')[1].Trim()
if ($value -eq '0x42') {
    Log "Value is $value - writing..."
    & $rwExe /Min /Nologo /Stdout /Command="WPCI $pciAddr 0x40" | Tee-Object -Variable tempOutput | Out-Null
    Log "Write output: $tempOutput"
} else {
    Log "Value is $value - no action"
}
