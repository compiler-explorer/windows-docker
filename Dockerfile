FROM mcr.microsoft.com/windows/servercore:ltsc2022

LABEL Description="CE for Windows" Vendor="compilerexplorer" Version="0.0.1"

WORKDIR C:\\tmp

RUN powershell -Command Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.3.1/PowerShell-7.3.1-win-x64.msi" -Outfile "C:\tmp\PowerShell-7.3.1-win-x64.msi" && \
    msiexec /quiet /i PowerShell-7.3.1-win-x64.msi && \
    del /q PowerShell-7.3.1-win-x64.msi

RUN pwsh -Command Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe" -OutFile "C:\tmp\Git-2.28.0-64-bit.exe" && \
    Git-2.28.0-64-bit.exe /silent /verysilent && \
    del /q Git-2.28.0-64-bit.exe

RUN pwsh -Command Invoke-WebRequest -Uri "https://nodejs.org/download/release/v16.19.0/node-v16.19.0-x64.msi" -OutFile "C:\tmp\node-installer.msi" && \
    msiexec /quiet ALLUSERS=1 /i node-installer.msi && \
    del /q node-installer.msi

ADD run.ps1 run.ps1

ADD install.ps1 install.ps1

RUN pwsh -ExecutionPolicy ByPass -File "C:\\tmp\\install.ps1"

ADD compiler-explorer.local.properties compiler-explorer.local.properties
ADD c++.win32.properties c++.win32.properties
ADD pascal.win32.properties pascal.win32.properties
ADD empty.win32.properties empty.win32.properties

RUN mkdir C:\\compilerexplorer

CMD ["pwsh", "-ExecutionPolicy", "Bypass", "-File", "C:\\tmp\\run.ps1"]
