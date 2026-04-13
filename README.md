# 🖥️ System Information Script (PowerShell)

## 📌 Overview

This PowerShell script collects and displays essential system information from a Windows machine.
It is designed to help IT support technicians and system administrators quickly assess system health and configuration.

---

## 🎯 Purpose

* Automate system information gathering
* Reduce manual troubleshooting time
* Provide quick insights into machine specifications

---

## ⚙️ Features

This script retrieves:

* 🧠 CPU information
* 💾 RAM usage and total memory
* 🗄️ Disk space usage
* 🖥️ Operating System details
* 🌐 Network configuration
* ⚡ System uptime

---

## 🧪 Technologies Used

* PowerShell
* Windows Management Instrumentation (WMI)
* CIM (Common Information Model)

---

## 🚀 How to Run

1. Open PowerShell as Administrator
2. Navigate to the script directory:

   ```powershell
   cd path\to\your\script
   ```
3. Run the script:

   ```powershell
   .\SystemInfo.ps1
   ```

---

## 📸 Example Output

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="doc/System-info.png">
  <source media="(prefers-color-scheme: light)" srcset="doc/System-info.png">
  <img alt="System Information" src="doc/System-info.png">
</picture>

---

## 🧠 Concepts Demonstrated

* Variables
* Command usage
* System queries using `Get-CimInstance`
* Output formatting

---

## 🔐 Use Case

This script can be used in:

* IT Support troubleshooting
* System audits
* Pre-deployment checks
* Helpdesk diagnostics

---

## 📈 Future Improvements

* Export results to a file (CSV/JSON)
* Add remote computer support
* Include GPU information
* Build a GUI version

---
