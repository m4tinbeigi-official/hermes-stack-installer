<!-- DevSponsors Badges -->
<p align="center">
  <a href="https://devsponsors.github.io"><img src="https://img.shields.io/badge/DevSponsors-Verified_OSS-6366f1?style=for-the-badge&logo=github" alt="DevSponsors Verified"></a>
  <a href="https://devsponsors.github.io"><img src="https://img.shields.io/badge/Sponsor-DevSponsors_Hub-emerald?style=for-the-badge&logo=github-sponsors" alt="DevSponsors Sponsor"></a>
  <a href="https://devsponsors.github.io/mediakit.html"><img src="https://img.shields.io/badge/Infrastructure-DevSponsors_Cloud-ec4899?style=for-the-badge&logo=server" alt="DevSponsors Cloud"></a>
</p>

<div align="center">

# 🚀 Hermes Stack Installer

### The all-in-one, zero-config installer for the Hermes AI Agent ecosystem

**Hermes Agent** · **Hermes WebUI** · **9Router** · **OmniRoute**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-blue)](#-platform-support)
[![Shell](https://img.shields.io/badge/shell-bash%20%7C%20PowerShell-informational)](#-quick-install)

One command. Every component detected, installed, wired together, and running — with the dashboard links and any generated credentials dropped straight into a text file for you.

</div>

---

## ✨ What is this?

Hermes Stack Installer is a single script (`install.sh` for Linux/macOS, `install.ps1` for Windows) that stands up the **entire Hermes AI agent ecosystem** on a fresh machine in one shot:

| Component | Role | Port |
| :-- | :-- | :-- |
| 🧠 **Hermes Agent** | Autonomous terminal agent — the core CLI brain | — |
| 🖥️ **Hermes WebUI** | Browser-based chat, session & tool manager | `8787` |
| 🔀 **9Router** | Lightweight AI gateway / model proxy | `20128` |
| 🌐 **OmniRoute** | Smart multi-model router with automatic fallback | `20129` |

No manual dependency chasing, no port collisions, no hand-editing config files — the installer detects your OS, installs whatever is missing, wires every component to the others, and hands you back a clean summary.

---

## ⚡️ Quick Install

### Linux & macOS

```bash
curl -fsSL https://raw.githubusercontent.com/m4tinbeigi-official/hermes-stack-installer/main/install.sh | bash
```

Fully unattended (auto-confirms every prompt):

```bash
curl -fsSL https://raw.githubusercontent.com/m4tinbeigi-official/hermes-stack-installer/main/install.sh | bash -s -- --yes
```

Force a clean reinstall of every component:

```bash
curl -fsSL https://raw.githubusercontent.com/m4tinbeigi-official/hermes-stack-installer/main/install.sh | bash -s -- --reinstall
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/m4tinbeigi-official/hermes-stack-installer/main/install.ps1 | iex
```

Or clone first and run locally with flags:

```powershell
git clone https://github.com/m4tinbeigi-official/hermes-stack-installer.git
cd hermes-stack-installer
./install.ps1 -Yes
```

> 💡 When the install finishes, a `dashboard-info.txt` file is written **in the folder you ran the command from** — it contains every dashboard URL and any generated API key/password. Keep it somewhere safe.

---

## 🌟 Key Features

- **🔍 Automatic OS & architecture detection** — Ubuntu, Debian, Fedora, Arch, macOS (Intel & Apple Silicon), WSL, and native Windows.
- **📦 Smart prerequisite handling** — checks for `git`, `curl`, `python3`, `node`/`npm`, `uv` (and `winget` packages on Windows), installing anything missing automatically.
- **♻️ No duplicate installs** — if a component already exists, you're asked whether to reuse it or do a clean reinstall.
- **🚦 Zero port conflicts by design** — every service is pinned to its own dedicated port out of the box.
- **🔗 Automatic wiring** — Hermes Agent's `config.yaml` is generated and pointed at the local 9Router endpoint with a freshly generated API key, with zero manual editing.
- **📝 One final summary, always** — a plain-text file with every dashboard link (and password/API key, if one was generated) is saved next to where you ran the installer.
- **🎛️ Simple lifecycle commands** — start, stop, and check the status of the whole stack with one word.
- **🎨 Polished CLI output** — colorized, step-by-step, professional terminal feedback on every platform.

---

## 🛠 Stack Architecture

```
                     ┌─────────────────────┐
                     │     Hermes Agent     │  (autonomous CLI core)
                     └──────────┬───────────┘
                                │  config.yaml → base_url + api_key
                                ▼
   ┌────────────────┐   ┌──────────────┐   ┌───────────────────┐
   │  Hermes WebUI   │   │   9Router    │   │     OmniRoute      │
   │  :8787          │──▶│   :20128     │──▶│      :20129        │
   │  chat & control │   │  AI gateway  │   │ multi-model router │
   └────────────────┘   └──────────────┘   └───────────────────┘
```

| Component | Port | Description |
| :--- | :--- | :--- |
| **Hermes WebUI** | `8787` | Browser dashboard and control panel |
| **9Router** | `20128` | AI proxy for local/cloud models |
| **OmniRoute** | `20129` | Smart router with automatic provider fallback |
| **Hermes Agent** | CLI | Autonomous terminal assistant and gateway client |

---

## 📋 Managing the Stack

### Linux / macOS

```bash
# Start everything in the background
~/.hermes-stack/start.sh
# or
hermes-stack-start

# Check status & ports
~/.hermes-stack/status.sh
# or
hermes-stack-status

# Stop everything
~/.hermes-stack/stop.sh
# or
hermes-stack-stop
```

### Windows

```powershell
# Start everything in the background
%USERPROFILE%\.hermes-stack\start.ps1

# Check status & ports
%USERPROFILE%\.hermes-stack\status.ps1

# Stop everything
%USERPROFILE%\.hermes-stack\stop.ps1
```

---

## 📄 The `dashboard-info.txt` output

At the end of every install, a text file like this is generated in your current working directory:

```
Hermes Stack - Dashboard Links & Credentials
Generated: 2026-08-26 13:04:11
==============================================

Hermes WebUI : http://127.0.0.1:8787
9Router API  : http://127.0.0.1:20128
OmniRoute API: http://127.0.0.1:20129

Hermes Agent API key (used to authenticate against 9Router): sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Management:
  Start : ...\start.ps1
  Stop  : ...\stop.ps1
  Status: ...\status.ps1
  CLI   : hermes
```

No hunting through terminal scrollback or config files — everything you need to open your dashboards lives in one file.

---

## 💻 Platform Support

| OS | Script | Status |
| :-- | :-- | :-- |
| Ubuntu / Debian | `install.sh` | ✅ Fully supported |
| Fedora | `install.sh` | ✅ Fully supported |
| Arch Linux | `install.sh` | ✅ Fully supported |
| macOS (Intel & Apple Silicon) | `install.sh` | ✅ Fully supported |
| WSL2 | `install.sh` | ✅ Fully supported |
| Windows (native PowerShell) | `install.ps1` | ✅ Fully supported |

---

## 🧩 Requirements

The installer takes care of these automatically, but for reference the stack ultimately relies on:

- **Git** — cloning components
- **Python 3.10+** — Hermes Agent & Hermes WebUI runtime
- **Node.js / npm** — 9Router & OmniRoute
- **curl** (Linux/macOS) / **winget** (Windows) — fetching installers

---

## ❓ Troubleshooting

- **A port is already in use** — run the status command to see which service owns it, or edit the port variables at the top of the install script before running it.
- **`winget` command not found (Windows)** — install "App Installer" from the Microsoft Store, then rerun the script.
- **Reinstalling a single component** — rerun the installer with `--reinstall` (bash) or `-Reinstall` (PowerShell); you'll be prompted per component if not using `--yes`/`-Yes`.
- **Lost your API key** — check `~/.hermes/config.yaml` (Linux/macOS) or `%USERPROFILE%\.hermes\config.yaml` (Windows) — it's stored under `api_key`.

---

## 📜 License

MIT License — Developed with ❤️ by [matinbeigi](https://github.com/m4tinbeigi-official)
