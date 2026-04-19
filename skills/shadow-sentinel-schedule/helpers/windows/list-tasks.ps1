$ErrorActionPreference = 'Stop'

param(
    [string]$NamePrefix = 'ShadowSentinel'
)

Get-ScheduledTask | Where-Object { $_.TaskName -like "$NamePrefix*" } | Select-Object TaskName, State, TaskPath
