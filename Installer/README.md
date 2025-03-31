# Folder Structure
``` bash
.
├── install.sh               # Main entrypoint script
├── base.sh                  # Shared functions/utilities
├── init/
│   └── install.sh           # Installer for initial (local) VM
└── deploy/
    └── install.sh           # Installer for deploying to remote VM
```

# install.sh (root level)
- install.sh
- Parses argument (--init or --deploy)
- Loads base.sh
- Calls the relevant sub-installer (init/install.sh or deploy/install.sh)

# Usage
```bash
./install.sh --init    # Local VM setup
./install.sh --deploy  # Remote VM setup
````

