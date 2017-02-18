FROM microsoft/windowsservercore

# Setup env.
ENV CMAKE_VERSION 3.7.2

# Use Powershell as default shell
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN (New-Object System.Net.WebClient).DownloadFile('https://cmake.org/files/v3.7/cmake-{0}-win64-x64.zip' -f $env:CMAKE_VERSION, 'cmakeboot.zip') ; \
        Expand-Archive cmakeboot.zip -DestinationPath C:\cmake ; \
        Remove-Item -Path cmakeboot.zip
