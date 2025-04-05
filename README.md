# ZTCloud Installer

ZTCloud is a modular installer system to manage multiple VPS servers with a clean, reproducible structure.

- Fully modular scripts under `/opt/ztcloud/scripts/`
- Configuration-driven via `/opt/ztcloud/config/config.sh`
- Central logging to `/opt/ztcloud/log/installer.log`
- No hardcoded settings — fully portable

---

## 📦 Installer Structure

| Path | Purpose |
|:-----|:--------|
| `/opt/ztcloud/install.sh` | Main installer script |
| `/opt/ztcloud/config/config.sh` | Configurable variables (Git repo, package list, app install toggles) |
| `/opt/ztcloud/scripts/common.sh` | Shared installer functions (logging, Git sync, base packages) |
| `/opt/ztcloud/scripts/*.sh` | Modular app install scripts |
| `/opt/ztcloud/log/installer.log` | Central log file |

---

## 🚀 Quick Start

**Full install (with real execution):**
```bash
bash /opt/ztcloud/install.sh
```
or use the remote installer
```bash
wget -O - https://raw.githubusercontent.com/ZTCloud-Sysadmin/ZTCloud/main/install.sh | bash
```

Dry-run mode (simulate install without making changes):

```bash
bash /opt/ztcloud/install.sh --dry-run
```
or use the remote installer
```bash
wget -O - https://raw.githubusercontent.com/ZTCloud-Sysadmin/ZTCloud/main/install.sh --dry-run | bash
```

(Coming soon: full dry-run support across all modular scripts.)

⚙️ Base System Requirements

* Debian 12 / Ubuntu 22.04+

* Minimal system packages (curl, git, sudo)         (auto-installed if missing)

* Root or sudo privileges

🔧 Configuration
Modify /opt/ztcloud/config/config.sh to:

* Change the Git repo

* Select which apps to install (Docker, Tailscale, ETCD, Caddy)

* Add/remove system packages to install

* Toggle dry-run and package install behavior

📜 License
MIT License

ZTCloud is designed for fast, safe, and reproducible VPS automation.
Built for sysadmins, by sysadmins.