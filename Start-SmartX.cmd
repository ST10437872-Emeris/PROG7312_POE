@echo off
setlocal
cd /d "%~dp0"
where dotnet >nul 2>nul
if errorlevel 1 goto missing_sdk
dotnet --list-sdks | findstr /b "10." >nul
if errorlevel 1 goto missing_sdk
echo Starting Smart-X at http://localhost:5080
echo Keep this window open while using the application. Press Ctrl+C to stop.
start "" /b powershell -NoProfile -Command "$smartxUrl='http://localhost:5080'; for($smartxAttempt=0;$smartxAttempt -lt 90;$smartxAttempt++){try{Invoke-WebRequest ($smartxUrl+'/api/health') -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop | Out-Null; Start-Process $smartxUrl; break}catch{Start-Sleep -Seconds 1}}"
dotnet run --project src/SmartX.Api -c Release
if errorlevel 1 pause
exit /b
:missing_sdk
echo Install the .NET 10 SDK, then run this file again.
echo Download: https://dotnet.microsoft.com/download/dotnet/10.0
pause
exit /b 1
