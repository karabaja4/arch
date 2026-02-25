$logFile = "C:\tools\fixnet.log"
$rweExe = "C:\tools\rwe\Rw.exe"

$deviceId = "0x125C8086"
$registerOffset = "0xB0"
$registerExpectedValue = "0x42"
$registerWriteValue = "0x40"

function Log ($message) {
    $timestamped = "[$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK')] $message"
    Write-Host $timestamped
    $timestamped | Out-File -FilePath $logFile -Append
}

function InvokeRwe ($command) {
    Log "Command: $command"
    $output = & $rweExe /Min /Nologo /Stdout /Command="$command" | Select-Object -First 1
    $result = '0xFFFF'
    if ($output -match ".+ = (0x[0-9A-Fa-f]+)") {
        $result = $Matches[1]
    }
    Log "Result: $result"
    return $result
}

Log "--- Start ---"

$bdf = InvokeRwe "FPCI $deviceId 0"
if ($bdf -ne '0xFFFF') {
    $registerValue = InvokeRwe "eRPCI $bdf $registerOffset"
    if ($registerValue -eq $registerExpectedValue) {
        Log "Value $registerValue OK, writing $registerWriteValue"
        $null = InvokeRwe "eWPCI $bdf $registerOffset $registerWriteValue"
    } else {
        Log "Value is $registerValue, expected $registerExpectedValue"
    }
} else {
    Log "Device not found ($bdf)"
}

Log "--- End ---"
