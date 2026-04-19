$ErrorActionPreference = 'Stop'

$workingDirectory = '{{WORKING_DIRECTORY}}'
$stdoutPath = '{{STDOUT_PATH}}'
$stderrPath = '{{STDERR_PATH}}'
$rawStdoutPath = '{{RAW_STDOUT_PATH}}'
$rawStderrPath = '{{RAW_STDERR_PATH}}'

New-Item -ItemType Directory -Force -Path (Split-Path $stdoutPath) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $stderrPath) | Out-Null
if ($rawStdoutPath -and $rawStdoutPath -ne '__NONE__') { New-Item -ItemType Directory -Force -Path (Split-Path $rawStdoutPath) | Out-Null }
if ($rawStderrPath -and $rawStderrPath -ne '__NONE__') { New-Item -ItemType Directory -Force -Path (Split-Path $rawStderrPath) | Out-Null }

$process = Start-Process -FilePath '{{PROGRAM}}' `
    -ArgumentList @(
{{ARGUMENT_LINES}}
    ) `
    -WorkingDirectory $workingDirectory `
    -RedirectStandardOutput $stdoutPath `
    -RedirectStandardError $stderrPath `
    -Wait `
    -PassThru `
    -NoNewWindow

if ($rawStdoutPath -and $rawStdoutPath -ne '__NONE__') {
    if (Test-Path $stdoutPath) {
        Copy-Item -Force $stdoutPath $rawStdoutPath
    } else {
        Set-Content -Path $rawStdoutPath -Value ''
    }
}

if ($rawStderrPath -and $rawStderrPath -ne '__NONE__') {
    if (Test-Path $stderrPath) {
        Copy-Item -Force $stderrPath $rawStderrPath
    } else {
        Set-Content -Path $rawStderrPath -Value ''
    }
}

$finalStdout = if (Test-Path $stdoutPath) { Get-Content -Path $stdoutPath -Raw } else { '' }
$finalStderr = if (Test-Path $stderrPath) { Get-Content -Path $stderrPath -Raw } else { '' }

if ($null -eq $finalStdout) { $finalStdout = '' }
if ($null -eq $finalStderr) { $finalStderr = '' }

Set-Content -Path $stdoutPath -Value $finalStdout
Set-Content -Path $stderrPath -Value $finalStderr

exit $process.ExitCode
