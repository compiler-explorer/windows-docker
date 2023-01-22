Write-Host "Installing AWS tools, might take a while"
Install-Module -Name AWSPowerShell -Force
Set-DefaultAWSRegion -Region us-east-1
Write-Host "Done installing AWS Tools"

Write-Host "Installing Grafana agent"
Invoke-WebRequest -Uri "https://github.com/grafana/agent/releases/download/v0.30.2/grafana-agent-installer.exe" -OutFile "C:\tmp\grafana-agent-installer.exe"
C:\\tmp\\grafana-agent-installer.exe /S
# Remove-Item -Path "C:\tmp\grafana-agent-installer.exe" # installer is run in the background, so cant delete it yet

Write-Host "Installing windows-exporter"
Invoke-WebRequest -Uri "https://github.com/prometheus-community/windows_exporter/releases/download/v0.20.0/windows_exporter-0.20.0-amd64.msi" -OutFile "C:\tmp\windows_exporter-0.20.0-amd64.msi"
msiexec /quiet /i "C:\tmp\windows_exporter-0.20.0-amd64.msi"

Remove-Item -Path "C:\tmp\windows_exporter-0.20.0-amd64.msi"


# todo populate C:\Program Files\Grafana Agent\agent-config.yaml with things
