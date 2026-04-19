param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,

    [Parameter(Mandatory = $true)]
    [string]$Execute,

    [Parameter(Mandatory = $false)]
    [string]$Arguments = '',

    [Parameter(Mandatory = $true)]
    [datetime]$At,

    [Parameter(Mandatory = $false)]
    [timespan]$RepetitionInterval,

    [Parameter(Mandatory = $false)]
    [timespan]$RepetitionDuration,

    [Parameter(Mandatory = $false)]
    [string]$Description = 'Shadow Sentinel scheduled job.'
)

$ErrorActionPreference = 'Stop'

Import-Module ScheduledTasks

$action = if ([string]::IsNullOrWhiteSpace($Arguments)) {
    New-ScheduledTaskAction -Execute $Execute
} else {
    New-ScheduledTaskAction -Execute $Execute -Argument $Arguments
}

if ($PSBoundParameters.ContainsKey('RepetitionInterval') -and $PSBoundParameters.ContainsKey('RepetitionDuration')) {
    $trigger = New-ScheduledTaskTrigger -Once -At $At -RepetitionInterval $RepetitionInterval -RepetitionDuration $RepetitionDuration
} else {
    $trigger = New-ScheduledTaskTrigger -Once -At $At
}

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew

try {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
} catch {
}

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Description $Description | Out-Null
Get-ScheduledTask -TaskName $TaskName | Select-Object TaskName, State
