@echo off
setlocal

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
echo System Health Check Menu
echo =======================================
echo 1. Quick Status Check (/CheckHealth)
echo 2. Detailed Scan (/ScanHealth)
echo 3. Repair System Image (/RestoreHealth)
echo 4. Scan and Repair System Files (sfc /scannow)
echo 5. System Update Repair
echo 6. Run commands 2, 3, 4 Sequentially
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

:: ===========================================
:: COMMON FUNCTIONS
:: ===========================================

:run_command_with_validation
:: Function to run command and validate success
:: Usage: call :run_command_with_validation "command" "operation_name" restart_recommended
set "command=%~1"
set "operation_name=%~2"
set "restart_rec=%~3"

echo Running %operation_name%...
echo.
%command%
set "cmd_result=%errorlevel%"

if %cmd_result% equ 0 (
    echo.
    echo [SUCCESS] %operation_name% completed successfully.
    if "%restart_rec%"=="1" call :show_restart_recommendation
) else (
    echo.
    echo [WARNING] %operation_name% completed with error code %cmd_result%.
    echo This may indicate issues that require attention.
)
goto :eof

:show_restart_recommendation
echo.
echo [RECOMMENDATION] A system restart is recommended to complete this operation.
goto :eof

:confirm_destructive_operation
:: Function to confirm destructive operations
:: Usage: call :confirm_destructive_operation "operation_description"
set "operation_desc=%~1"
echo.
echo [WARNING] %operation_desc%
echo This operation will modify system files and may affect system stability.
echo.
set /p confirm=Do you want to continue? (Y/N): 
if /i not "%confirm%"=="Y" (
    echo Operation cancelled.
    pause
    goto menu
)
goto :eof

:: ===========================================
:: MENU OPERATIONS
:: ===========================================

:checkhealth
call :run_command_with_validation "DISM.exe /Online /Cleanup-Image /CheckHealth" "Quick Status Check" 0
pause
goto menu

:scanhealth
call :confirm_destructive_operation "This will perform a detailed scan of your system image."
call :run_command_with_validation "DISM.exe /Online /Cleanup-Image /ScanHealth" "Detailed Scan" 0
pause
goto menu

:restorehealth
call :confirm_destructive_operation "This will attempt to repair your system image and may download files from Windows Update."
call :run_command_with_validation "DISM.exe /Online /Cleanup-Image /RestoreHealth" "System Image Repair" 1
pause
goto menu

:sfcscan
call :confirm_destructive_operation "This will scan and repair system files, potentially replacing corrupted files."
call :run_command_with_validation "sfc /scannow" "System File Checker" 1
pause
goto menu

:updatefix
call :confirm_destructive_operation "This will stop services, rename system folders, and reset Windows Update components."
echo Running System Update Repair...
echo.

:: Start the TrustedInstaller service to allow modifications to system files
echo Configuring TrustedInstaller service...
SC config trustedinstaller start= auto >nul 2>&1
net start trustedinstaller >nul 2>&1

:: Stop update-related services
echo Stopping update services...
net stop bits >nul 2>&1
net stop wuauserv >nul 2>&1
net stop msiserver >nul 2>&1
net stop cryptsvc >nul 2>&1
net stop appidsvc >nul 2>&1

if %errorlevel% neq 0 (
    echo [WARNING] Some services may not have stopped properly (Error: %errorlevel%).
)

:: Rename update-related folders to allow fresh start
echo Renaming SoftwareDistribution and catroot2 folders...
if exist "%SystemRoot%\SoftwareDistribution" (
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set "datestamp=%%c-%%a-%%b"
    Ren "%SystemRoot%\SoftwareDistribution" "SoftwareDistribution.%datestamp%.old" >nul 2>&1
    if %errorlevel% neq 0 echo [WARNING] Failed to rename SoftwareDistribution folder.
)

if exist "%SystemRoot%\System32\catroot2" (
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set "datestamp=%%c-%%a-%%b"
    Ren "%SystemRoot%\System32\catroot2" "catroot2.%datestamp%.old" >nul 2>&1
    if %errorlevel% neq 0 echo [WARNING] Failed to rename catroot2 folder.
)

:: Re-register critical DLLs
echo Re-registering system DLLs...
regsvr32.exe /s atl.dll >nul 2>&1
regsvr32.exe /s urlmon.dll >nul 2>&1
regsvr32.exe /s mshtml.dll >nul 2>&1

:: Reset network components and proxy
echo Resetting network and proxy settings...
netsh winsock reset >nul 2>&1
netsh winsock reset proxy >nul 2>&1

:: Remove unused drivers
echo Cleaning up unused drivers...
rundll32.exe pnpclean.dll,RunDLL_PnpClean /DRIVERS /MAXCLEAN >nul 2>&1

:: Perform DISM component cleanup
echo Performing component cleanup...
DISM.exe /Online /Cleanup-image /StartComponentCleanup >nul 2>&1
if %errorlevel% neq 0 echo [WARNING] Component cleanup completed with warnings.

:: Restart update services
echo Restarting update services...
net start bits >nul 2>&1
net start wuauserv >nul 2>&1
net start msiserver >nul 2>&1
net start cryptsvc >nul 2>&1
net start appidsvc >nul 2>&1

echo.
echo [SUCCESS] System Update Repair completed.
call :show_restart_recommendation
pause
goto menu

:all
call :confirm_destructive_operation "This will run Detailed Scan, System Image Repair, and System File Checker sequentially."
echo Running Core Repair Commands Sequentially...
echo.

echo === Step 1 of 3: Detailed Scan ===
call :run_command_with_validation "DISM.exe /Online /Cleanup-Image /ScanHealth" "Detailed Scan" 0

echo.
echo === Step 2 of 3: System Image Repair ===
call :run_command_with_validation "DISM.exe /Online /Cleanup-Image /RestoreHealth" "System Image Repair" 0

echo.
echo === Step 3 of 3: System File Checker ===
call :run_command_with_validation "sfc /scannow" "System File Checker" 0

echo.
echo [SUCCESS] System repair commands completed.
echo It is strongly recommended to restart your computer now to complete any repairs.
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
echo - Runs a quick check to determine if the system image has any corruption.
echo.
echo 2. Detailed Scan (/ScanHealth):
echo - Scans the system image for any signs of corruption, which may take a few minutes.
echo.
echo 3. Repair System Image (/RestoreHealth):
echo - Attempts to repair any issues found in the system image, downloading files if needed.
echo.
echo 4. Scan and Repair System Files (sfc /scannow):
echo - Runs a System File Checker scan to repair corrupted system files and ensure system integrity.
echo.
echo 5. System Update Repair:
echo - Fixes issues with Windows Update by stopping update services, renaming critical folders,
echo resetting network components, and cleaning unused drivers.
echo.
echo 6. Run commands 2, 3, 4 Sequentially:
echo - Runs the three core repair commands in optimal order: Detailed Scan, System Image Repair,
echo and System File Checker. Always recommends a restart after completion. Does not include update repair.
echo.
echo ============================================================
pause
goto menu
