# WiFi Credential Auditor

Windows-based offensive security tool that silently extracts all saved WiFi credentials from a target machine via USB autorun, using PowerShell and VBScript. Built for authorized endpoint auditing and personal security research.

---

## Legal Notice

This tool is intended exclusively for use on devices owned by the user or explicitly authorized by the device owner or network administrator. Running it on systems without authorization may constitute a criminal offense under applicable law. The author assumes no liability for unauthorized use. Use responsibly.

---

## Overview

WiFi Credential Auditor automates the extraction of all WiFi profiles stored by Windows, including network names (SSIDs) and their saved passwords in plain text. It operates completely silently — no windows, no prompts, no visible activity — and saves the results in a structured report directly on the USB drive.

The tool was built to demonstrate how easily credential data stored by the operating system can be accessed, and to raise awareness about endpoint credential exposure as part of a personal security research project.

---

## How It Works

The tool is composed of three files that work together:

**autorun.inf**
Configures the USB drive so that when it is connected to a Windows machine, the system presents an "Extract WiFi Passwords" action in the autoplay dialog. If the user selects it, the extraction begins automatically.

**invisible.vbs**
A VBScript launcher that calls PowerShell with completely hidden execution — no terminal window, no taskbar icon, no visual trace on screen.

**stealth.ps1**
The core PowerShell script. It performs the following steps:
1. Suppresses its own window via a Win32 API call to `ShowWindow`
2. Runs `netsh wlan show profiles` to list all saved WiFi profiles on the machine
3. For each profile, runs `netsh wlan show profile name="..." key=clear` to retrieve the stored password in plain text
4. Writes the results to a UTF-16 encoded `.txt` file inside the `wifi_data/` folder on the USB drive
5. Names the output file with the machine hostname and timestamp for traceability
6. Exits silently after a 3-second delay

---

## Output Format

The report is saved as `wifi_data/wifi_<hostname>_<YYYYMMDD_HHMMSS>.txt` directly on the USB drive. Each execution generates a new file, preserving the audit history across multiple runs.

```
=====================================================
Contrasenas WiFi Extraidas - HOSTNAME
Fecha: 04/02/2026 16:29:32
=====================================================

SSID: HomeNetwork_5G
Password: mypassword123
----------------------------------------
SSID: OpenNetwork
(sin contrasena guardada)
----------------------------------------
SSID: Office_Secure
Password: officepass2024
----------------------------------------
```

---

## Tech Stack

```
Language:     PowerShell, VBScript
System calls: Win32 API (user32.dll ShowWindow), netsh wlan
Output:       UTF-16 encoded plain text file
Target OS:    Windows 10 / 11
Deployment:   USB drive with autorun.inf trigger
```

---

## Repository Structure

```
wifi-credential-auditor/
├── autorun.inf        USB autoplay configuration
├── invisible.vbs      Silent PowerShell launcher
├── stealth.ps1        Core extraction script
├── wifi_data/         Output folder (generated at runtime, gitignored)
└── README.md
```

---

## Why This Was Built

This project started as a practical exercise to understand how Windows stores and exposes network credentials at the operating system level. The goal was to learn firsthand what an attacker can access from a machine in under 10 seconds, and to understand what defensive measures (such as disabling autorun, restricting PowerShell execution policy, or using credential managers) would mitigate the risk.

Understanding the attack is the first step toward building effective defenses.

---

