# Run once in an elevated PowerShell session on Windows Server 2025 if OpenSSH
# is not already prepared for Ansible. If SSH already works with PowerShell,
# you do not need to run this script.
#
# This script is language-agnostic and works on Windows Server in any language.

$ErrorActionPreference = 'Stop'

$ssh = Get-WindowsCapability -Online -Name 'OpenSSH.Server*'
if ($ssh.State -ne 'Installed') {
    Add-WindowsCapability -Online -Name $ssh.Name | Out-Null
}

Set-Service -Name sshd -StartupType Automatic
Start-Service -Name sshd

if (-not (Get-NetFirewallRule -Name 'sshd-Server-In-TCP' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule `
        -Name 'sshd-Server-In-TCP' `
        -DisplayName 'OpenSSH Server (sshd)' `
        -Enabled True `
        -Direction Inbound `
        -Protocol TCP `
        -Action Allow `
        -LocalPort 22 | Out-Null
}

New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null

# Detect PowerShell path (works in any Windows language)
$systemRoot = $env:SystemRoot
$powershellPath = "$systemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

# Verify PowerShell exists
if (-not (Test-Path $powershellPath)) {
    Write-Error "PowerShell not found at: $powershellPath"
    exit 1
}

New-ItemProperty `
    -Path 'HKLM:\SOFTWARE\OpenSSH' `
    -Name 'DefaultShell' `
    -Value $powershellPath `
    -PropertyType String `
    -Force | Out-Null

Write-Host "OpenSSH is ready for Ansible using Windows PowerShell."
Write-Host "DefaultShell configured to: $powershellPath"
