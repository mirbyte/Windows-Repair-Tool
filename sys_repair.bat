@echo off
:: Ensure script is run with administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges. Please run it as an administrator.
    pause
    exit /b
)

:menu
cls
echo =======================================
echo        System Health Check Menu
echo =======================================
echo 1. Quick Status Check (/CheckHealth)
echo 2. Detailed Scan (/ScanHealth)
echo 3. Repair System Image (/RestoreHealth)
echo 4. Scan and Repair System Files (sfc /scannow)
echo 5. System Update Repair
echo 6. Run All Sequentially
echo 7. Restart System
echo 8. Restart System Goto BIOS
echo 9. Help - Command Descriptions
echo 10. Exit
echo =======================================
set /p choice=Select an option (1-10): 

if "%choice%"=="1" goto checkhealth
if "%choice%"=="2" goto scanhealth
if "%choice%"=="3" goto restorehealth
if "%choice%"=="4" goto sfcscan
if "%choice%"=="5" goto updatefix
if "%choice%"=="6" goto all
if "%choice%"=="7" goto restart
if "%choice%"=="8" goto restartbios
if "%choice%"=="9" goto help
if "%choice%"=="10" exit

echo Invalid option, please try again.
echo.
pause
goto menu

:checkhealth
echo Running Quick Status Check...
echo.
DISM /Online /Cleanup-Image /CheckHealth
pause
goto menu

:scanhealth
echo Running Detailed Scan...
echo.
DISM /Online /Cleanup-Image /ScanHealth
pause
goto menu

:restorehealth
echo Running System Image Repair...
echo.
DISM /Online /Cleanup-Image /RestoreHealth
pause
goto menu

:sfcscan
echo Running System File Checker...
echo.
sfc /scannow
pause
goto menu

:updatefix
echo Running System Update Repair...
echo.

:: Start the TrustedInstaller service to allow modifications to system files
echo Configuring TrustedInstaller service...
SC config trustedinstaller start=auto
net start trustedinstaller

:: Stop update-related services
echo Stopping update services...
net stop bits
net stop wuauserv
net stop msiserver
net stop cryptsvc
net stop appidsvc

:: Rename update-related folders to allow fresh start
echo Renaming SoftwareDistribution and catroot2 folders...
Ren %Systemroot%\SoftwareDistribution SoftwareDistribution.old
Ren %Systemroot%\System32\catroot2 catroot2.old

:: Re-register critical DLLs
echo Re-registering system DLLs...
regsvr32.exe /s atl.dll
regsvr32.exe /s urlmon.dll
regsvr32.exe /s mshtml.dll

:: Reset network components and proxy
echo Resetting network and proxy settings...
netsh winsock reset
netsh winsock reset proxy

:: Remove unused drivers
echo Cleaning up unused drivers...
rundll32.exe pnpclean.dll,RunDLL_PnpClean /DRIVERS /MAXCLEAN

:: Perform DISM component cleanup
echo Performing component cleanup...
dism /Online /Cleanup-image /StartComponentCleanup

:: Restart update services
echo Restarting update services...
net start bits
net start wuauserv
net start msiserver
net start cryptsvc
net start appidsvc

echo System Update Repair completed.
pause
goto menu

:all
echo Running All Commands Sequentially...
echo.
echo Starting Quick Status Check...
DISM /Online /Cleanup-Image /CheckHealth
echo.
echo Starting Detailed Scan...
DISM /Online /Cleanup-Image /ScanHealth
echo.
echo Starting System Image Repair...
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo Starting System File Checker...
sfc /scannow
echo.
echo Starting System Update Repair...
call :updatefix
echo All commands completed.
pause
goto menu

:restart 
echo Restarting System...
shutdown /r /t 0
exit

:restartbios
echo Restarting System to BIOS...
shutdown /r /fw /t 0
exit

:help
cls
echo ======================= Help Section =======================
echo 1. Quick Status Check (/CheckHealth):
echo    - Runs a quick check to determine if the system image has any corruption.
echo.
echo 2. Detailed Scan (/ScanHealth):
echo    - Scans the system image for any signs of corruption, which may take a few minutes.
echo.
echo 3. Repair System Image (/RestoreHealth):
echo    - Attempts to repair any issues found in the system image, downloading files if needed.
echo.
echo 4. Scan and Repair System Files (sfc /scannow):
echo    - Runs a System File Checker scan to repair corrupted system files and ensure system integrity.
echo.
echo 5. System Update Repair:
echo    - Fixes issues with Windows Update by stopping update services, renaming critical folders, 
echo      resetting network components, and cleaning unused drivers.
echo.
echo 6. Run All Sequentially:
echo    - Runs all the above commands in sequence for a comprehensive health check and repair.
echo.
echo ============================================================
pause
goto menu
