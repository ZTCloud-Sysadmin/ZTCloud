# ZTCloud
/opt/ZTCloud/
├── install.sh                 # Main installer script (downloaded via wget)
└── installer/                 # Cloned GitHub repository contents
    ├── scripts/               # Modular install scripts
    │   ├── log.sh             # Centralized logging module
    │   ├── ntp.sh             # System clock synchronization (NTP setup)
    │   ├── init.sh            # Base system package installation
    │   ├── git.sh             # Git repository clone + permissions fix
    │   └── (more modules...)  # Additional setup scripts (future expansion)
    └── (other folders/files)  # Future: configuration templates, apps, etc.

/opt/log/installer/
└── ztcloud-install.log         # Unified log file for all install operations


# Run Command
wget -O - https://raw.githubusercontent.com/ZTCloud-Sysadmin/ZTCloud/main/install.sh | bash







# OLD ISTALLER
Normal run:
```bash
wget -O - https://raw.githubusercontent.com/ZTCloud-Sysadmin/ZTCloud/main/bootstrap.sh | bash -s -- --init
```

Dry-run mode:
```bash
wget -O - https://raw.githubusercontent.com/ZTCloud-Sysadmin/ZTCloud/main/bootstrap.sh | bash -s -- --dry-run --init
```

Clock-Reste/ usefull when you are restoring from backup/snapshot
```bash
wget -O - https://raw.githubusercontent.com/ZTCloud-Sysadmin/ZTCloud/main/bootstrap.sh | bash -s -- --force-clock-reset --init
```