# GBL-AutoRoot — Changelog

## v2.1 — Auto-Driver Install

### ✨ New Features
- **Auto-Driver Installation (Smart Detect)**
  - Automatically detects if a connected Android device is missing the correct ADB/Fastboot USB drivers using Windows WMI.
  - Prompts to auto-download and install the **Official Google USB Drivers** silently.
  - Native Windows UAC integration (requests permission cleanly without suspicious third-party installers).
  - Helps users who plug in their phone but see "No device detected" due to missing drivers.
- **Unauthorized Device Warning**
  - If ADB sees a device as `unauthorized`, it now prints a helpful yellow warning telling the user to check their phone screen and tap "Allow", instead of treating it as no device.

## v2.0 — 2026-10-01

### 🐛 Bug Fixes
- **FIXED: Script getting stuck when phone is already in Fastboot mode**
  - Old `wait_for_device` only scanned ADB. If phone was plugged in via Fastboot, script would wait 60 seconds and fail.
  - New `detect_any_device` scans **both ADB and Fastboot simultaneously** every 2 seconds.
  - Phone detected in either mode → correct path chosen automatically.

### ✨ New Features

1. **Smart Dual-Mode Auto-Detection**
   - Auto-detects device in ADB mode OR Fastboot mode
   - If already in Fastboot → skips reboot step, jumps straight to exploit
   - If in ADB → reboots to fastboot, then exploits

2. **Pre-Flight Compatibility Check (Step 4)**
   - Verifies Qualcomm SoC before running exploit
   - Warns if firmware version is in known-patched range (HyperOS 3.0.304+)
   - Shows bootloader state (locked/unlocked)
   - User can abort if warnings appear

3. **Persistent Loop Mode**
   - After successful exploit, asks: "Enable Loop Mode?"
   - If YES → waits for device to reboot, then auto-applies root again
   - Useful for users who need root after every reboot

4. **Session Log File**
   - Auto-creates `log_YYYYMMDD_HHMMSS.txt` in the script folder
   - Logs: device info, all commands, fastboot responses, result
   - Useful for debugging and sharing results with community

5. **Offline Mode Support**
   - If `platform-tools` folder already exists → uses it silently
   - No "download failed" errors when running offline
   - Downloads only if tools are completely missing

6. **Color-Coded Output**
   - Green = success / pass
   - Yellow = warning / info  
   - Red = error / fail
   - Cyan = step headers and progress

7. **Better Fastboot Recovery**
   - If exploit fails → auto-sends `fastboot reboot` to recover device
   - No more manually rebooting stuck phones

8. **Improved Device Info (Fastboot path)**
   - Now reads `product` and `version-baseband` via fastboot when in bootloader mode
   - v1.0 showed "Unknown" for everything when device was in Fastboot

---

## v1.0 — Initial Release

- Basic ADB-only detection
- Auto-download platform-tools
- CVE-2026-24088 ABL injection exploit
- Retry / Cleanup menu
