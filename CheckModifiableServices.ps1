# Current user
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

# All write-type rights to check
$writeRights = @(
    "FullControl",
    "WriteKey",
    "SetValue",
    "CreateSubKey",
    "TakeOwnership"
)

# Get services
Get-WmiObject Win32_Service | ForEach-Object {
    $serviceName = $_.Name
    $serviceDisplay = $_.DisplayName

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$serviceName"
    try {
        $acl = Get-Acl $regPath
    } catch {
        return
    }

    # Check if user has any write variant
    $userHasAccess = $acl.Access | Where-Object {
        ($_.IdentityReference -eq $currentUser) -and 
        ($writeRights -contains $_.RegistryRights.ToString())
    }

    if ($userHasAccess) {
        [PSCustomObject]@{
            ServiceName = $serviceName
            DisplayName = $serviceDisplay
            StartMode = $_.StartMode
            ServiceAccount = $_.StartName
            CurrentUserWriteAccess = $true
            RegistryRights = ($userHasAccess | ForEach-Object { $_.RegistryRights }) -join ", "
        }
    }
} | Format-Table -AutoSize