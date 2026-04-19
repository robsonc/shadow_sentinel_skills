param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,

    [int]$WaitSeconds = 5
)

$ErrorActionPreference = 'Stop'

Start-ScheduledTask -TaskName $TaskName
Start-Sleep -Seconds $WaitSeconds
Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo | Select-Object LastRunTime, LastTaskResult, NextRunTime
