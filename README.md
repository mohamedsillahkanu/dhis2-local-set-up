# 🚀 DHIS2 One-Command Installer for Windows

Install DHIS2 locally in under 5 minutes with Docker - **automatically installs all prerequisites**!

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![DHIS2 Version](https://img.shields.io/badge/DHIS2-2.40.5-blue)](https://github.com/dhis2/dhis2-releases)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078D6)](https://www.microsoft.com/windows)

## ✨ Features

- 🎯 **One command installation** - Just clone and run
- 🔧 **Auto-installs prerequisites** - Docker and Git installed automatically if missing
- 🐳 **Docker-based** - Isolated, reproducible environment
- 🗄️ **PostgreSQL 15 with PostGIS** - Full spatial database support
- 💾 **Persistent data** - Your data survives restarts
- 🔒 **Secure by default** - Isolated network and volumes
- 📦 **Zero configuration** - Works out of the box

## 🚀 Installation (Super Easy!)

### For Windows Users

**Just 3 steps:**

1. **Right-click PowerShell** and select **"Run as Administrator"**

2. **Copy and paste this:**

```powershell
git clone https://github.com/mohamedsillahkanu/dhis2-local-set-up.git
cd dhis2-quick-install
.\install-windows.ps1
```

3. **Done!** The script will:
   - ✅ Check if Git is installed (installs if missing)
   - ✅ Check if Docker is installed (installs if missing)
   - ✅ Download and start DHIS2
   - ✅ Show you the login credentials

### No Prerequisites Needed!

The installer automatically installs:
- Git (if you don't have it)
- Docker Desktop (if you don't have it)
- DHIS2 and PostgreSQL (always fresh install)

**Just run the script and everything is handled for you!**

## 🌐 Access DHIS2

After installation completes (3-5 minutes):

- **URL:** http://localhost:8080
- **Username:** `admin`
- **Password:** `district`

> ⚠️ **Important:** Change the default password immediately after first login!

## 📊 Useful Commands

```powershell
# Navigate to installation directory
cd dhis2-quick-install

# Check if containers are running
docker ps

# View DHIS2 logs
docker-compose logs -f dhis2

# View database logs
docker-compose logs -f database

# Stop DHIS2 (keeps your data)
docker-compose stop

# Start DHIS2 again
docker-compose start

# Restart DHIS2
docker-compose restart

# Remove containers (keeps data in volumes)
docker-compose down

# Complete removal (deletes ALL data)
docker-compose down -v
```

## 🛠️ What Gets Installed

| Component | Version | Port | Description |
|-----------|---------|------|-------------|
| Git | Latest | - | Version control (if not installed) |
| Docker Desktop | Latest | - | Container platform (if not installed) |
| DHIS2 Core | 2.40.5 | 8080 | Health information system |
| PostgreSQL | 15 | 5432 | Database with PostGIS extension |

## 🔧 Troubleshooting

### The Script Handles Most Issues Automatically!

The installer checks and fixes:
- ✅ Missing Git → Installs it
- ✅ Missing Docker → Installs it
- ✅ Docker not running → Prompts you to start it
- ✅ Already running → Offers to restart

### Common Manual Fixes

**"Must run as Administrator"**
- Right-click PowerShell → Select "Run as Administrator"
- Run the script again

**"Docker needs restart after installation"**
- The script will prompt you to restart
- After restart, run the script again
- Docker will work properly

**Port 8080 already in use**
1. Open `docker-compose.yml` in Notepad
2. Change line `- "8080:8080"` to `- "8081:8080"`
3. Save the file
4. Run `docker-compose down` then `.\install-windows.ps1` again
5. Access DHIS2 at http://localhost:8081

**Installation hangs or freezes**
```powershell
# Press Ctrl+C to stop
# Clean up and restart:
docker-compose down -v
.\install-windows.ps1
```

**First startup is slow (3-5 minutes)**
- This is normal for first time!
- Docker downloads ~2GB of images
- Database initializes
- DHIS2 sets up tables
- **Subsequent startups take only 30 seconds**

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Windows Computer                │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Docker Container: dhis2-app     │ │
│  │   DHIS2 Core 2.40.5               │ │
│  │   Port: 8080 → localhost:8080     │ │
│  └───────────────────────────────────┘ │
│              ↕ Network                  │
│  ┌───────────────────────────────────┐ │
│  │   Docker Container: dhis2-db      │ │
│  │   PostgreSQL 15 + PostGIS         │ │
│  │   Port: 5432 (internal)           │ │
│  └───────────────────────────────────┘ │
│              ↕                          │
│  ┌───────────────────────────────────┐ │
│  │   Docker Volumes (Persistent)     │ │
│  │   - dhis2-data (app files)        │ │
│  │   - dhis2-db-data (database)      │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## 📚 Next Steps After Installation

### 1. Change Default Password (CRITICAL!)

1. Login with `admin` / `district`
2. Click your profile picture (top right)
3. Click "Edit user settings"
4. Go to "Account" tab
5. Enter a new secure password
6. Click "Save"

### 2. Explore DHIS2

- **Dashboard:** View data visualizations
- **Data Entry:** Input health data
- **Reports:** Generate analytics and reports
- **Maintenance:** Configure system settings

### 3. Set Up Your Organization

1. **Organization Units:** Maintenance → Organization unit
   - Define your hierarchy (Country → Region → District → Facility)
   
2. **User Roles:** Users → User role
   - Create different access levels
   
3. **Data Elements:** Maintenance → Data element
   - Define what data you'll collect
   
4. **Indicators:** Maintenance → Indicator
   - Set up calculated metrics

### 4. Import Demo Data (Optional - Great for Learning!)

1. Go to Import/Export app
2. Click "Data Import"
3. Upload sample datasets
4. Perfect for testing and training

### 5. Learn DHIS2

- **User Manual:** https://docs.dhis2.org/en/use/user-guides/dhis-core-version-master/dhis2-user-manual.html
- **Implementation Guide:** https://docs.dhis2.org/en/implement/implement.html
- **Video Tutorials:** https://www.youtube.com/c/dhis2
- **DHIS2 Academy:** https://academy.dhis2.org

## 💡 Tips and Best Practices

### Backup Your Data

```powershell
# Backup database volume
docker run --rm -v dhis2-db-data:/data -v ${PWD}:/backup alpine tar czf /backup/dhis2-db-backup.tar.gz /data

# Backup DHIS2 files volume
docker run --rm -v dhis2-data:/data -v ${PWD}:/backup alpine tar czf /backup/dhis2-backup.tar.gz /data
```

### Update DHIS2 to Newer Version

1. Edit `docker-compose.yml`
2. Change `image: dhis2/core:2.43.1.0` to desired version
3. Run:
```powershell
docker-compose down
docker-compose pull
docker-compose up -d
```

### Monitor System Resources

```powershell
# Check Docker container stats
docker stats

# Check disk usage
docker system df

# View container details
docker inspect dhis2-app
docker inspect dhis2-db
```

### Clean Up Docker (Free Disk Space)

```powershell
# Remove unused images
docker image prune -a

# Remove unused volumes (CAREFUL!)
docker volume prune

# Complete cleanup (VERY CAREFUL!)
docker system prune -a --volumes
```

## 🔗 Resources

- [DHIS2 Official Website](https://dhis2.org)
- [DHIS2 Documentation](https://docs.dhis2.org)
- [DHIS2 Community Forum](https://community.dhis2.org)
- [DHIS2 Academy](https://academy.dhis2.org)
- [DHIS2 GitHub](https://github.com/dhis2/dhis2-core)
- [Docker Desktop Docs](https://docs.docker.com/desktop/windows/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## ❓ FAQ

### Do I need to install anything first?

**No!** Just run the script as Administrator. It automatically installs Git and Docker if you don't have them.

### Can I run this on Windows 10 Home?

Yes! You need Windows 10 Home version 2004 or higher with WSL 2 enabled. Docker Desktop will set this up for you.

### How much disk space do I need?

Minimum 10GB free space. DHIS2 and Docker images take about 5-6GB, plus space for your data.

### Can I access DHIS2 from other computers?

Yes! Find your computer's IP address with `ipconfig`, then access from other devices at `http://YOUR-IP:8080`. Make sure Windows Firewall allows port 8080.

### Is my data safe if I stop the containers?

Yes! Data is stored in Docker volumes that persist even when containers are stopped or removed. Only `docker-compose down -v` deletes data.

### Can I upgrade DHIS2 later?

Yes! Edit `docker-compose.yml`, change the version number, then run `docker-compose down && docker-compose pull && docker-compose up -d`.

### How do I completely uninstall everything?

```powershell
cd dhis2-quick-install
docker-compose down -v
cd ..
Remove-Item -Recurse -Force dhis2-quick-install
```

To also remove Docker Desktop:
1. Open "Add or Remove Programs"
2. Find "Docker Desktop"
3. Click "Uninstall"

## 🤝 Contributing

Found a bug? Have a suggestion? Want to improve the installer?

1. Open an [Issue](https://github.com/YOUR-USERNAME/dhis2-quick-install/issues)
2. Fork the repository
3. Create a Pull Request

## 📄 License

MIT License - Free to use, modify, and distribute.

See [LICENSE](LICENSE) file for full details.

## ⭐ Support This Project

If this installer helped you:
- ⭐ Give it a star on GitHub
- 📢 Share it with others working with DHIS2
- 🐛 Report bugs or suggest improvements
- 📝 Improve the documentation

## 📞 Get Help

- **GitHub Issues:** [Open an issue](https://github.com/YOUR-USERNAME/dhis2-quick-install/issues)
- **DHIS2 Community:** https://community.dhis2.org
- **DHIS2 Documentation:** https://docs.dhis2.org
- **Email Support:** Post on DHIS2 Community Forum

## 🙏 Acknowledgments

- DHIS2 Team for the amazing health information platform
- Docker for containerization technology
- PostgreSQL and PostGIS teams
- The open-source community

---

Made with ❤️ for the DHIS2 community

**Happy DHIS2 deploying! 🚀**

---

### Quick Reference Card

```
┌─────────────────────────────────────┐
│      DHIS2 Quick Reference          │
├─────────────────────────────────────┤
│ URL:      http://localhost:8080     │
│ Username: admin                     │
│ Password: district                  │
│                                     │
│ Install:  .\install-windows.ps1    │
│ Logs:     docker-compose logs -f    │
│ Stop:     docker-compose stop       │
│ Start:    docker-compose start      │
│ Status:   docker ps                 │
│ Remove:   docker-compose down -v    │
└─────────────────────────────────────┘
```
