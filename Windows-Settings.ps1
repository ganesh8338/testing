# 1. Turn off the Windows Firewall for all profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-Host "Firewall has been turned off."

# 2. Ensure PowerShell version 5.1 or above is installed
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -ge 5) {
    Write-Host "PowerShell version $($psVersion.Major).$($psVersion.Minor) is installed. Proceeding with configuration."
} else {
    Write-Host "PowerShell version 5.1 or above is required. Please update PowerShell first."
    Exit
}

# 3. Enable WinRM and configure required settings
# Running WinRM quick config
winrm quickconfig -q
Write-Host "WinRM quick config completed."

# Setting WinRM service authentication to allow Basic authentication
winrm set winrm/config/service/Auth '@{Basic="true"}'
Write-Host "WinRM Basic authentication enabled."

# Allowing unencrypted traffic
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
Write-Host "WinRM unencrypted traffic allowed."

# Setting maximum memory per shell to 1024MB
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
Write-Host "MaxMemoryPerShellMB set to 1024."

# 4. Enable PS Remoting
Enable-PSRemoting -Force
Write-Host "PowerShell Remoting enabled."

# 5. Configure WinRM Local Group Policy automatically using PowerShell registry settings
Write-Host "Configuring Local Group Policy settings for WinRM."

# Setting Trusted Hosts in WinRM Client to '*'
$trustedHostsRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $trustedHostsRegPath -Name "TrustedHosts" -Value "*"
Write-Host "Trusted Hosts set to '*'"

# Enabling remote server management through WinRM for both IPV4 and IPV6
$winrmServiceRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service"
Set-ItemProperty -Path $winrmServiceRegPath -Name "AllowRemoteServerManagementThroughWinRM" -Value 1
Write-Host "Allow remote server management through WinRM has been enabled."

# 6. Enable PowerShell script execution for remote signed scripts
Write-Host "Enabling script execution policy for remote signed scripts."
Set-ExecutionPolicy RemoteSigned -Force
Write-Host "Execution policy set to RemoteSigned."

# 7. Set Windows Autologon (Netplwiz) for the Administrator user
Write-Host "Enabling autologon for Administrator account."
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value "Administrator"
Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value "Unitrends1"
Write-Host "Autologon has been enabled for the Administrator account."

# 8. Enable PowerShell script execution policy for local scripts
$psPolicyRegPath = "HKCU:\Software\Policies\Microsoft\Windows\PowerShell"
Set-ItemProperty -Path $psPolicyRegPath -Name "EnableScripts" -Value 1
Write-Host "Enabled PowerShell script execution for local scripts."

# 9. Set max memory per shell (WinRM Service) via Registry
$winrsRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $winrsRegPath -Name "MaxMemoryPerShellMB" -Value 1024
Write-Host "MaxMemoryPerShellMB set to 1024."

# 10. Reboot the system to apply all changes
Write-Host "Rebooting the system to apply all changes."
Restart-Computer -Force
