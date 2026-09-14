<#
.SYNOPSIS
    Disables the built-in local Administrator account identified by RID 500.

.PARAMETER EventSource
    Optional existing Windows Event Log source. If present, a success event
    with ID 10001 is written to the Application log.
#>

[CmdletBinding()]
param(
    [string]$EventSource = 'Windows PowerShell'
)

try {
    $Account = Get-CimInstance `
        -ClassName Win32_UserAccount `
        -Filter "LocalAccount=True" `
        -ErrorAction Stop |
        Where-Object { $_.SID -match '-500$' } |
        Select-Object -First 1

    if (-not $Account) {
        Write-Output 'No local RID-500 account was found. No change required.'
        exit 0
    }

    if ($Account.Disabled) {
        Write-Output "Built-in Administrator account '$($Account.Name)' is already disabled."
        exit 0
    }

    $Sid = [System.Security.Principal.SecurityIdentifier]$Account.SID
    Disable-LocalUser -SID $Sid -ErrorAction Stop

    $Verified = Get-CimInstance `
        -ClassName Win32_UserAccount `
        -Filter "LocalAccount=True" |
        Where-Object { $_.SID -eq $Account.SID }

    if (-not $Verified.Disabled) {
        throw 'Account verification failed after Disable-LocalUser.'
    }

    $Message = "Built-in Administrator account '$($Account.Name)' was disabled."

    if ([System.Diagnostics.EventLog]::SourceExists($EventSource)) {
        Write-EventLog `
            -LogName Application `
            -Source $EventSource `
            -EventId 10001 `
            -EntryType Information `
            -Message $Message
    }

    Write-Output $Message
    exit 0
}
catch {
    Write-Output "Remediation failed: $($_.Exception.Message)"
    exit 1
}
