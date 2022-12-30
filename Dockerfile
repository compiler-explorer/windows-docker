FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL Description="CE for Windows" Vendor="compilerexplorer" Version="0.0.1"

WORKDIR C:\\tmp

RUN powershell -Command Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.28.0.windows.1/Git-2.28.0-64-bit.exe" -OutFile "C:\tmp\Git-2.28.0-64-bit.exe" && \
    Git-2.28.0-64-bit.exe /silent /verysilent && \
    del /q Git-2.28.0-64-bit.exe

RUN powershell -Command Invoke-WebRequest -Uri "https://nodejs.org/download/release/v16.19.0/node-v16.19.0-x64.msi" -OutFile "C:\tmp\node-installer.msi" && \
    msiexec /quiet /i node-installer.msi && \
    del /q node-installer.msi

ADD setup-ce.ps1 setup-ce.ps1

RUN powershell -ExecutionPolicy Bypass -File C:\\tmp\\setup-ce.ps1

WORKDIR C:\\compilerexplorer

ADD compiler-explorer.local.properties etc/config/compiler-explorer.local.properties
ADD c++.win32.properties etc/config/c++.win32.properties
ADD pascal.win32.properties etc/config/pascal.win32.properties
ADD empty.win32.properties etc/config/python.win32.properties
ADD empty.win32.properties etc/config/hlsl.win32.properties
ADD empty.win32.properties etc/config/ocaml.win32.properties
ADD empty.win32.properties etc/config/rust.win32.properties
ADD empty.win32.properties etc/config/hook.win32.properties
ADD empty.win32.properties etc/config/circle.win32.properties
ADD empty.win32.properties etc/config/cpp2_cppfront.win32.properties

ADD run.ps1 run.ps1


CMD ["powershell", "-ExecutionPolicy", "Bypass", "-File", "C:\\tmp\\run.ps1"]
