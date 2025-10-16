#!/usr/bin/env pwsh
# ============================================
# DHIS2 Quick Installer for Windows
# Auto-installs Docker and Git if missing
# Version: 2.0.0
# ============================================

$ErrorActionPreference = "Stop"

# Check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

# Install Chocolatey if needed
function Install-Chocolatey {
    Write-ColorOutput "`n📦 Installing Chocolatey package manager..." "Cyan"
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-ColorOutput "✅ Chocolatey installed successfully" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "❌ Failed to install Chocolatey: $_" "Red"
        return $false
    }
}

# Install Git if missing
function Install-GitIfMissing {
    Write-ColorOutput "`n🔍 Checking for Git..." "Yellow"
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $version = (git --version) -replace 'git version ', ''
        Write-ColorOutput "✅ Git is already installed (Version: $version)" "Green"
        return $true
    }
    
    if (-not (Test-Administrator)) {
        Write-ColorOutput "❌ Git not found and script is not running as Administrator" "Red"
        Write-ColorOutput "`nPlease either:" "Yellow"
        Write-ColorOutput "  1. Install Git manually from: https://git-scm.com/download/win" "White"
        Write-ColorOutput "  2. OR run this script as Administrator to auto-install`n" "White"
        return $false
    }
    
    Write-ColorOutput "📥 Installing Git automatically..." "Cyan"
    
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        if (-not (Install-Chocolatey)) {
            Write-ColorOutput "❌ Cannot install Git without Chocolatey" "Red"
            Write-ColorOutput "Please install Git manually: https://git-scm.com/download/win`n" "Yellow"
            return $false
        }
    }
    
    try {
        Write-ColorOutput "Downloading and installing Git (may take a few minutes)..." "Cyan"
        choco install git -y --force
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Verify
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $version = (git --version) -replace 'git version ', ''
            Write-ColorOutput "✅ Git installed successfully (Version: $version)" "Green"
            return $true
        }
        else {
            Write-ColorOutput "⚠️  Git installed but not detected. Please restart PowerShell." "Yellow"
            Write-ColorOutput "Close PowerShell and run this script again.`n" "Yellow"
            exit 0
        }
    }
    catch {
        Write-ColorOutput "❌ Failed to install Git: $_" "Red"
        Write-ColorOutput "Please install manually: https://git-scm.com/download/win`n" "Yellow"
        return $false
    }
}

# Install Docker if missing
function Install-DockerIfMissing {
    Write-ColorOutput "`n🔍 Checking for Docker..." "Yellow"
    
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        try {
            $version = (docker --version) -replace 'Docker version ', '' -replace ',.*', ''
            Write-ColorOutput "✅ Docker is installed (Version: $version)" "Green"
            
            # Check if Docker is running
            $null = docker ps 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✅ Docker is running" "Green"
                return $true
            }
            else {
                Write-ColorOutput "⚠️  Docker is installed but not running" "Yellow"
                Write-ColorOutput "`nPlease:" "Cyan"
                Write-ColorOutput "  1. Open Docker Desktop from Start menu" "White"
                Write-ColorOutput "  2. Wait for Docker to start (2-3 minutes)" "White"
                Write-ColorOutput "  3. Press Enter to continue..." "White"
                Read-Host
                
                $null = docker ps 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorOutput "✅ Docker is now running" "Green"
                    return $true
                }
                else {
                    Write-ColorOutput "❌ Docker is still not running" "Red"
                    Write-ColorOutput "Please start Docker Desktop and run this script again.`n" "Yellow"
                    return $false
                }
            }
        }
        catch {
            Write-ColorOutput "⚠️  Docker command found but not working" "Yellow"
        }
    }
    
    if (-not (Test-Administrator)) {
        Write-ColorOutput "❌ Docker not found and script is not running as Administrator" "Red"
        Write-ColorOutput "`nPlease either:" "Yellow"
        Write-ColorOutput "  1. Install Docker Desktop manually: https://www.docker.com/products/docker-desktop" "White"
        Write-ColorOutput "  2. OR run this script as Administrator to auto-install`n" "White"
        return $false
    }
    
    Write-ColorOutput "📥 Installing Docker Desktop automatically..." "Cyan"
    Write-ColorOutput "This will take 10-15 minutes. Please be patient..." "Yellow"
    
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        if (-not (Install-Chocolatey)) {
            Write-ColorOutput "❌ Cannot install Docker without Chocolatey" "Red"
            Write-ColorOutput "Please install Docker manually: https://www.docker.com/products/docker-desktop`n" "Yellow"
            return $false
        }
    }
    
    try {
        choco install docker-desktop -y --force
        
        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-ColorOutput "`n✅ Docker Desktop installed successfully!" "Green"
        Write-ColorOutput "`n⚠️  IMPORTANT: You MUST restart your computer for Docker to work" "Red"
        Write-ColorOutput "`nAfter restarting:" "Cyan"
        Write-ColorOutput "  1. Open Docker Desktop from Start menu" "White"
        Write-ColorOutput "  2. Wait for it to start (2-3 minutes)" "White"
        Write-ColorOutput "  3. Run this script again`n" "White"
        
        $response = Read-Host "Do you want to restart your computer now? (Y/n)"
        if ($response -ne 'n' -and $response -ne 'N') {
            Write-ColorOutput "`n🔄 Restarting computer in 10 seconds..." "Yellow"
            Write-ColorOutput "Press Ctrl+C to cancel`n" "Red"
            Start-Sleep -Seconds 10
            Restart-Computer -Force
        }
        
        exit 0
    }
    catch {
        Write-ColorOutput "❌ Failed to install Docker Desktop: $_" "Red"
        Write-ColorOutput "`nPlease install manually:" "Yellow"
        Write-ColorOutput "  1. Go to: https://www.docker.com/products/docker-desktop" "White"
        Write-ColorOutput "  2. Download and run installer" "White"
        Write-ColorOutput "  3. Restart your computer" "White"
        Write-ColorOutput "  4. Run this script again`n" "White"
        return $false
    }
}

# Check if containers are already running
function Test-ContainersRunning {
    $running = docker ps --filter "name=dhis2" --format "{{.Names}}" 2>$null
    if ($running) {
        Write-ColorOutput "`n⚠️  DHIS2 containers are already running!" "Yellow"
        Write-ColorOutput "Found running: $running" "Cyan"
        
        $response = Read-Host "`nDo you want to restart them? (y/N)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Write-ColorOutput "`n🔄 Restarting containers..." "Cyan"
            docker-compose restart
            Write-ColorOutput "`n✅ Containers restarted successfully!" "Green"
            Write-ColorOutput "`n🌐 Access DHIS2 at: http://localhost:8080" "Cyan"
            Write-ColorOutput "👤 Username: admin" "Yellow"
            Write-ColorOutput "🔑 Password: district`n" "Yellow"
            exit 0
        }
        else {
            Write-ColorOutput "`nℹ️  DHIS2 is already running at: http://localhost:8080`n" "Cyan"
            exit 0
        }
    }
}

# Main installation function
function Start-Installation {
    # Print banner
    Write-ColorOutput "`n╔════════════════════════════════════════════╗" "Cyan"
    Write-ColorOutput "║   DHIS2 Quick Installer for Windows       ║" "Cyan"
    Write-ColorOutput "║   Version 2.0.0 with Auto-Install         ║" "Cyan"
    Write-ColorOutput "╚════════════════════════════════════════════╝`n" "Cyan"
    
    # Check prerequisites and install if missing
    if (-not (Install-GitIfMissing)) { 
        Write-ColorOutput "`n❌ Cannot continue without Git`n" "Red"
        exit 1 
    }
    
    if (-not (Install-DockerIfMissing)) { 
        Write-ColorOutput "`n❌ Cannot continue without Docker`n" "Red"
        exit 1 
    }
    
    Write-ColorOutput "`n✅ All prerequisites are ready!`n" "Green"
    
    # Check for docker-compose.yml
    if (-not (Test-Path "docker-compose.yml")) {
        Write-ColorOutput "❌ docker-compose.yml not found!" "Red"
        Write-ColorOutput "Please make sure you're in the correct directory.`n" "Yellow"
        exit 1
    }
    
    # Check if already running
    Test-ContainersRunning
    
    # Pull images
    Write-ColorOutput "📦 Downloading Docker images..." "Cyan"
    Write-ColorOutput "   (First time only, ~2GB - may take several minutes)`n" "Yellow"
    
    try {
        docker-compose pull
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to pull images"
        }
    }
    catch {
        Write-ColorOutput "`n❌ Failed to download images!" "Red"
        Write-ColorOutput "Error: $_" "Red"
        Write-ColorOutput "`nPlease check your internet connection and try again.`n" "Yellow"
        exit 1
    }
    
    # Start containers
    Write-ColorOutput "`n🚀 Starting DHIS2 containers..." "Cyan"
    
    try {
        docker-compose up -d
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to start containers"
        }
    }
    catch {
        Write-ColorOutput "`n❌ Failed to start containers!" "Red"
        Write-ColorOutput "Error: $_" "Red"
        Write-ColorOutput "`nTry running: docker-compose down -v" "Yellow"
        Write-ColorOutput "Then run this script again.`n" "Yellow"
        exit 1
    }
    
    # Success message
    Write-ColorOutput "`n╔════════════════════════════════════════════╗" "Green"
    Write-ColorOutput "║          ✅ DHIS2 Started Successfully!    ║" "Green"
    Write-ColorOutput "╚════════════════════════════════════════════╝" "Green"
    
    Write-ColorOutput "`n📋 Connection Details:" "Cyan"
    Write-ColorOutput "   🌐 URL:      " -NoNewline
    Write-ColorOutput "http://localhost:8080" "Yellow"
    Write-ColorOutput "   👤 Username: " -NoNewline
    Write-ColorOutput "admin" "Yellow"
    Write-ColorOutput "   🔑 Password: " -NoNewline
    Write-ColorOutput "district" "Yellow"
    
    Write-ColorOutput "`n⏳ First startup takes 3-5 minutes..." "Magenta"
    Write-ColorOutput "   Watch progress: " -NoNewline
    Write-ColorOutput "docker-compose logs -f dhis2" "Cyan"
    
    Write-ColorOutput "`n⚠️  SECURITY: Change password immediately after first login!" "Red"
    
    Write-ColorOutput "`n💡 Useful Commands:" "Cyan"
    Write-ColorOutput "   • View logs:    docker-compose logs -f" "White"
    Write-ColorOutput "   • Stop DHIS2:   docker-compose stop" "White"
    Write-ColorOutput "   • Start DHIS2:  docker-compose start" "White"
    Write-ColorOutput "   • Check status: docker ps" "White"
    
    # Ask if user wants to see logs
    $response = Read-Host "`nDo you want to watch the startup logs now? (Y/n)"
    
    if ($response -ne 'n' -and $response -ne 'N') {
        Write-ColorOutput "`n📊 Showing live logs (Press Ctrl+C to exit)...`n" "Blue"
        Start-Sleep -Seconds 2
        docker-compose logs -f
    }
    else {
        Write-ColorOutput "`n✅ Installation started successfully!" "Green"
        Write-ColorOutput "Run 'docker-compose logs -f' anytime to watch the logs.`n" "Cyan"
    }
}

# Run the installation
try {
    Start-Installation
}
catch {
    Write-ColorOutput "`n❌ An unexpected error occurred!" "Red"
    Write-ColorOutput "Error: $_" "Red"
    Write-ColorOutput "`nPlease check the error message and try again.`n" "Yellow"
    exit 1
}
