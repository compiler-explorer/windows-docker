
Invoke-WebRequest -Uri "https://github.com/grafana/agent/releases/download/v0.30.2/grafana-agent-installer.exe" -OutFile "C:\tmp\grafana-agent-installer.exe"
C:\\tmp\\grafana-agent-installer.exe /S
# Remove-Item -Path "C:\tmp\grafana-agent-installer.exe" # installer is run in the background, so cant delete it yet

Invoke-WebRequest -Uri "https://github.com/prometheus-community/windows_exporter/releases/download/v0.20.0/windows_exporter-0.20.0-amd64.msi" -OutFile "C:\tmp\windows_exporter-0.20.0-amd64.msi"
msiexec /quiet /i "C:\tmp\windows_exporter-0.20.0-amd64.msi"

Remove-Item -Path "C:\tmp\windows_exporter-0.20.0-amd64.msi"

function CreateCEUser {
    $pass = ConvertTo-SecureString "pwd" -AsPlainText -Force
    
    New-LocalUser -User "ce" -Password $pass -PasswordNeverExpires -FullName "CE" -Description "Special user for running Compiler Explorer"

    Add-LocalGroupMember -Group "Users" -Member "ce"
}

function DenyAccessByCE {
    param (
        $Path
    )

    $ACL = Get-ACL -Path $Path
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("ce", "FullControl", "Deny")
    $ACL.AddAccessRule($AccessRule)
    $ACL | Set-Acl -Path $Path
}

CreateCEUser
DenyAccessByCE -Path "C:\Program Files\Grafana Agent\agent-config.yaml"

# todo populate C:\Program Files\Grafana Agent\agent-config.yaml with things
