# ZTCloud

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