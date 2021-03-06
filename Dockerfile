# escape=`
FROM windowsservercore_java:latest

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV GIT_VERSION 2.11.0
ENV GIT_TAG v${GIT_VERSION}.windows.1
ENV GIT_DOWNLOAD_URL https://github.com/git-for-windows/git/releases/download/${GIT_TAG}/Git-${GIT_VERSION}-64-bit.exe
ENV GIT_DOWNLOAD_SHA256 fd1937ea8468461d35d9cabfcdd2daa3a74509dc9213c43c2b9615e8f0b85086
# steps inspired by "chcolateyInstall.ps1" from "git.install" (https://chocolatey.org/packages/git.install)
RUN Write-Host ('Downloading {0} ...' -f $env:GIT_DOWNLOAD_URL); `
	Invoke-WebRequest -Uri $env:GIT_DOWNLOAD_URL -OutFile 'git.exe'; `
	`
	Write-Host ('Verifying sha256 ({0}) ...' -f $env:GIT_DOWNLOAD_SHA256); `
	if ((Get-FileHash git.exe -Algorithm sha256).Hash -ne $env:GIT_DOWNLOAD_SHA256) { `
		Write-Host 'FAILED!'; `
		exit 1; `
	}; `
	`
	Write-Host 'Installing ...'; `
	Start-Process `
		-Wait `
		-FilePath ./git.exe `
# http://www.jrsoftware.org/ishelp/topic_setupcmdline.htm
		-ArgumentList @( `
			'/VERYSILENT', `
			'/NORESTART', `
			'/NOCANCEL', `
			'/SP-', `
			'/SUPPRESSMSGBOXES', `
			`
# https://github.com/git-for-windows/build-extra/blob/353f965e0e2af3e8c993930796975f9ce512c028/installer/install.iss#L87-L96
			'/COMPONENTS=assoc_sh', `
			`
# set "/DIR" so we can set "PATH" afterwards
# see https://disqus.com/home/discussion/chocolatey/chocolatey_gallery_git_install_1710/#comment-2834659433 for why we don't use "/LOADINF=..." to let the installer set PATH
			'/DIR=C:\git' `
		); `
	`
	Write-Host 'Updating PATH ...'; `
	$env:PATH = 'C:\git\bin;C:\git\mingw64\bin;C:\git\usr\bin;' + $env:PATH; `
	[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); `
	`
	Write-Host 'Verifying install ...'; `
	Write-Host '  git --version'; git --version; `
	Write-Host '  bash --version'; bash --version; `
	Write-Host '  curl --version'; curl.exe --version; `
	`
	Write-Host 'Removing installer ...'; `
	Remove-Item git.exe -Force; `
	`
    Write-Host 'Complete.';
