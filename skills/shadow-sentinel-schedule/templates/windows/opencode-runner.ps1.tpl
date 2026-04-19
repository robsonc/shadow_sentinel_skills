$ErrorActionPreference = 'Stop'

$workingDirectory = '{{WORKING_DIRECTORY}}'
$stdoutPath = '{{STDOUT_PATH}}'
$stderrPath = '{{STDERR_PATH}}'
$rawStdoutPath = '{{RAW_STDOUT_PATH}}'
$rawStderrPath = '{{RAW_STDERR_PATH}}'
$opencodePath = '{{OPENCODE_PATH}}'

$prompt = @'
{{PROMPT_BLOCK}}
'@

New-Item -ItemType Directory -Force -Path (Split-Path $stdoutPath) | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path $stderrPath) | Out-Null
if ($rawStdoutPath -and $rawStdoutPath -ne '__NONE__') { New-Item -ItemType Directory -Force -Path (Split-Path $rawStdoutPath) | Out-Null }
if ($rawStderrPath -and $rawStderrPath -ne '__NONE__') { New-Item -ItemType Directory -Force -Path (Split-Path $rawStderrPath) | Out-Null }

$tempRoot = Join-Path $env:USERPROFILE '.shadow_sentinel\state\{{JOB_ID}}'
New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

$runToken = '{0}-{1}' -f (Get-Date -Format 'yyyyMMddHHmmssfff'), $PID
$tempRawStdoutPath = Join-Path $tempRoot ("$runToken.raw.jsonl")
$tempRawStderrPath = Join-Path $tempRoot ("$runToken.raw.stderr.txt")

foreach ($path in @($stdoutPath, $stderrPath, $rawStdoutPath, $rawStderrPath)) {
    if ([string]::IsNullOrWhiteSpace($path) -or $path -eq '__NONE__') {
        continue
    }

    if (Test-Path $path) {
        try {
            Remove-Item -Force $path -ErrorAction Stop
        }
        catch {
        }
    }
}

try {
    $process = Start-Process -FilePath $opencodePath `
        -ArgumentList @(
            'run',
            '--format',
            'json',
            $prompt
        ) `
        -WorkingDirectory $workingDirectory `
        -RedirectStandardOutput $tempRawStdoutPath `
        -RedirectStandardError $tempRawStderrPath `
        -Wait `
        -PassThru `
        -NoNewWindow

    $rawStdout = if (Test-Path $tempRawStdoutPath) {
        [string](Get-Content -Path $tempRawStdoutPath -Raw -ErrorAction SilentlyContinue)
    } else {
        ''
    }

    $rawStderr = if (Test-Path $tempRawStderrPath) {
        [string](Get-Content -Path $tempRawStderrPath -Raw -ErrorAction SilentlyContinue)
    } else {
        ''
    }

    if ($null -eq $rawStdout) { $rawStdout = '' }
    if ($null -eq $rawStderr) { $rawStderr = '' }

    $messages = New-Object System.Collections.Generic.List[string]
    if (-not [string]::IsNullOrWhiteSpace($rawStdout)) {
        foreach ($line in ($rawStdout -split "`r?`n")) {
            if ([string]::IsNullOrWhiteSpace($line)) { continue }

            try {
                $event = $line | ConvertFrom-Json -ErrorAction Stop
                if ($event.type -eq 'text' -and $null -ne $event.part -and -not [string]::IsNullOrWhiteSpace($event.part.text)) {
                    [void]$messages.Add($event.part.text)
                }
            }
            catch {
            }
        }
    }

    $finalStdout = ($messages -join [Environment]::NewLine).Trim()
    if ([string]::IsNullOrWhiteSpace($finalStdout)) {
        $finalStdout = $rawStdout.Trim()
    }

    if ($rawStdoutPath -and $rawStdoutPath -ne '__NONE__') {
        if (Test-Path $tempRawStdoutPath) {
            Copy-Item -Force $tempRawStdoutPath $rawStdoutPath
        } else {
            [System.IO.File]::WriteAllText($rawStdoutPath, '', [System.Text.Encoding]::ASCII)
        }
    }

    if ($rawStderrPath -and $rawStderrPath -ne '__NONE__') {
        if (Test-Path $tempRawStderrPath) {
            Copy-Item -Force $tempRawStderrPath $rawStderrPath
        } else {
            [System.IO.File]::WriteAllText($rawStderrPath, '', [System.Text.Encoding]::ASCII)
        }
    }

    [System.IO.File]::WriteAllText($stdoutPath, $finalStdout, [System.Text.Encoding]::ASCII)
    [System.IO.File]::WriteAllText($stderrPath, $rawStderr.Trim(), [System.Text.Encoding]::ASCII)

    foreach ($path in @($tempRawStdoutPath, $tempRawStderrPath)) {
        if (Test-Path $path) {
            try {
                Remove-Item -Force $path -ErrorAction Stop
            }
            catch {
            }
        }
    }

    if ($process.ExitCode -ne 0) {
        exit $process.ExitCode
    }

    exit 0
}
catch {
    $errorText = $_ | Out-String
    [System.IO.File]::WriteAllText($stdoutPath, '', [System.Text.Encoding]::ASCII)
    [System.IO.File]::WriteAllText($stderrPath, $errorText.Trim(), [System.Text.Encoding]::ASCII)
    exit 1
}
