# Intune Disable Built-in Administrator

Intune-ready PowerShell detection and remediation scripts for disabling the
built-in Windows local Administrator account.

The account is identified by its well-known **RID 500** suffix rather than by
the display name, so the approach works even when the built-in account has been
renamed.

## Intune

Use:

- Run as logged-on user: **No**
- 64-bit PowerShell: **Yes**
- Detection: `Detect-BuiltInAdministratorDisabled.ps1`
- Remediation: `Disable-BuiltInAdministrator.ps1`

The remediation verifies the resulting state and can write Application event
ID `10001` when the configured event source already exists.

Test on a pilot device and ensure an approved administrative access path such
as Windows LAPS is available before broad deployment.
