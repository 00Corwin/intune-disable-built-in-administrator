<#
.SYNOPSIS
    Intune detection script that checks whether the built-in local
    Administrator account (RID 500) is disabled.
#>

try {
    $Account = Get-CimInstance `
        -ClassName Win32_UserAccount `
        -Filter "LocalAccount=True" `
        -ErrorAction Stop |
        Where-Object { $_.SID -match '-500$' } |
        Select-Object -First 1

    if (-not $Account) {
        Write-Output 'Compliant: no local RID-500 account was found.'
        exit 0
    }

    if ($Account.Disabled) {
        Write-Output "Compliant: built-in Administrator account '$($Account.Name)' is disabled."
        exit 0
    }

    Write-Output "Non-compliant: built-in Administrator account '$($Account.Name)' is enabled."
    exit 1
}
catch {
    Write-Output "Detection failed: $($_.Exception.Message)"
    exit 1
}
