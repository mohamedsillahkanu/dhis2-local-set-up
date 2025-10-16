#!/usr/bin/env pwsh
# DHIS2 Quick Installer for Windows
# Auto-installs Docker and Git if missing
# Version: 2.0.0

$ErrorActionPreference = "Stop"

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Install-Chocolatey {
    Write-ColorOutput "`nInstalling Chocolatey package manager..." "Cyan"
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-ColorOutput "Chocolatey installed successfully" "Green"
        return $true
    }
    catch {
        Write-ColorOutput "Failed to install Chocolatey: $_" "Red"
        return $false
    }
}

function Install-GitIfMissing {
    Write-ColorOutput "`nChecking for Git..." "Yellow"
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $version = (git --version) -replace 'git version ', ''
        Write-ColorOutput "Git is already installed (Version: $version)" "Green"
        return $true
    }
    
    if (-not (Test-Administrator)) {
        Write-ColorOutput "Git not found and script is not running as Administrator" "Red"
        Write-ColorOutput "`nPlease either:" "Yellow"
        Write-ColorOutput "  1. Install Git manually from: https://git-scm.com/download/win" "White"
        Write-ColorOutput "  2. OR run this script as Administrator to auto-install`n" "White"
        return $false
    }
    
    Write-ColorOutput "Installing Git automatically..." "Cyan"
    
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        if (-not (Install-Chocolatey)) {
            Write-ColorOutput "Cannot install Git without Chocolatey" "Red"
            Write-ColorOutput "Please install Git manually: https://git-scm.com/download/win`n" "Yellow"
            return $false
        }
    }
    
    try {
        Write-ColorOutput "Downloading and installing Git (may take a few minutes)..." "Cyan"
        choco install git -y --force
        
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        if (Get-Command git -ErrorAction SilentlyContinue) {
            $version = (git --version) -replace 'git version ', ''
            Write-ColorOutput "Git installed successfully (Version: $version)" "Green"
            return $true
        }
        else {
            Write-ColorOutput "Git installed but not detected. Please restart PowerShell." "Yellow"
            Write-ColorOutput "Close PowerShell and run this script again.`n" "Yellow"
            exit 0
        }
    }
    catch {
        Write-ColorOutput "Failed to install Git: $_" "Red"
        Write-ColorOutput "Please install manually: https://git-scm.com/download/win`n" "Yellow"
        return $false
    }
}

function Install-DockerIfMissing {
    Write-ColorOutput "`nChecking for Docker..." "Yellow"
    
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        try {
            $version = (docker --version) -replace 'Docker version ', '' -replace ',.*', ''
            Write-ColorOutput "Docker is installed (Version: $version)" "Green"
            
            $null = docker ps 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "Docker is running" "Green"
                return $true
            }
            else {
                Write-ColorOutput "Docker is installed but not running" "Yellow"
                Write-ColorOutput "`nPlease:" "Cyan"
                Write-ColorOutput "  1. Open Docker Desktop from Start menu" "White"
                Write-ColorOutput "  2. Wait for Docker to start (2-3 minutes)" "White"
                Write-ColorOutput "  3. Press Enter to continue..." "White"
                Read-Host
                
                $null = docker ps 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorOutput "Docker is now running" "Green"
                    return $true
                }
                else {
                    Write-ColorOutput "Docker is still not running" "Red"
                    Write-ColorOutput "Please start Docker Desktop and run this script again.`n" "Yellow"
                    return $false
                }
            }
        }
        catch {
            Write-ColorOutput "Docker command found but not working" "Yellow"
        }
    }
    
    if (-not (Test-Administrator)) {
        Write-ColorOutput "Docker not found and script is not running as Administrator" "Red"
        Write-ColorOutput "`nPlease either:" "Yellow"
        Write-ColorOutput "  1. Install Docker Desktop manually: https://www.docker.com/products/docker-desktop" "White"
        Write-ColorOutput "  2. OR run this script as Administrator to auto-install`n" "White"
        return $false
    }
    
    Write-ColorOutput "Installing Docker Desktop automatically..." "Cyan"
    Write-ColorOutput "This will take 10-15 minutes. Please be patient..." "Yellow"
    
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        if (-not (Install-Chocolatey)) {
            Write-ColorOutput "Cannot install Docker without Chocolatey" "Red"
            Write-ColorOutput "Please install Docker manually: https://www.docker.com/products/docker-desktop`n" "Yellow"
            return $false
        }
    }
    
    try {
        choco install docker-desktop -y --force
        
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-ColorOutput "`nDocker Desktop installed successfully!" "Green"
        Write-ColorOutput "`nIMPORTANT: You MUST restart your computer for Docker to work" "Red"
        Write-ColorOutput "`nAfter restarting:" "Cyan"
        Write-ColorOutput "  1. Open Docker Desktop from Start menu" "White"
        Write-ColorOutput "  2. Wait for it to start (2-3 minutes)" "White"
        Write-ColorOutput "  3. Run this script again`n" "White"
        
        $response = Read-Host "Do you want to restart your computer now? (Y/n)"
        if ($response -ne 'n' -and $response -ne 'N') {
            Write-ColorOutput "`nRestarting computer in 10 seconds..." "Yellow"
            Write-ColorOutput "Press Ctrl+C to cancel`n" "Red"
            Start-Sleep -Seconds 10
            Restart-Computer -Force
        }
        
        exit 0
    }
    catch {
        Write-ColorOutput "Failed to install Docker Desktop: $_" "Red"
        Write-ColorOutput "`nPlease install manually:" "Yellow"
        Write-ColorOutput "  1. Go to: https://www.docker.com/products/docker-desktop" "White"
        Write-ColorOutput "  2. Download and run installer" "White"
        Write-ColorOutput "  3. Restart your computer" "White"
        Write-ColorOutput "  4. Run this script again`n" "White"
        return $false
    }
}

function Test-ContainersRunning {
    $running = docker ps --filter "name=dhis2" --format "{{.Names}}" 2>$null
    if ($running) {
        Write-ColorOutput "`nDHIS2 containers are already running!" "Yellow"
        Write-ColorOutput "Found running: $running" "Cyan"
        
        $response = Read-Host "`nDo you want to restart them? (y/N)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Write-ColorOutput "`nRestarting containers..." "Cyan"
            docker-compose restart
            Write-ColorOutput "`nContainers restarted successfully!" "Green"
            Write-ColorOutput "`nAccess DHIS2 at: http://localhost:8080" "Cyan"
            Write-ColorOutput "Username: admin" "Yellow"
            Write-ColorOutput "Password: district`n" "Yellow"
            exit 0
        }
        else {
            Write-ColorOutput "`nDHIS2 is already running at: http://localhost:8080`n" "Cyan"
            exit 0
        }
    }
}

function Start-Installation {
    Write-ColorOutput "`n===============================================" "Cyan"
    Write-ColorOutput "   DHIS2 Quick Installer for Windows" "Cyan"
    Write-ColorOutput "   Version 2.0.0 with Auto-Install" "Cyan"
    Write-ColorOutput "===============================================`n" "Cyan"
    
    if (-not (Install-GitIfMissing)) { 
        Write-ColorOutput "`nCannot continue without Git`n" "Red"
        exit 1 
    }
    
    if (-not (Install-DockerIfMissing)) { 
        Write-ColorOutput "`nCannot continue without Docker`n" "Red"
        exit 1 
    }
    
    Write-ColorOutput "`nAll prerequisites are ready!`n" "Green"
    
    if (-not (Test-Path "docker-compose.yml")) {
        Write-ColorOutput "docker-compose.yml not found!" "Red"
        Write-ColorOutput "Please make sure you're in the correct directory.`n" "Yellow"
        exit 1
    }
    
    Test-ContainersRunning
    
    Write-ColorOutput "Downloading Docker images..." "Cyan"
    Write-ColorOutput "(First time only, ~2GB - may take several minutes)`n" "Yellow"
    
    try {
        docker-compose pull
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to pull images"
        }
    }
    catch {
        Write-ColorOutput "`nFailed to download images!" "Red"
        Write-ColorOutput "Error: $_" "Red"
        Write-ColorOutput "`nPlease check your internet connection and try again.`n" "Yellow"
        exit 1
    }
    
    Write-ColorOutput "`nStarting DHIS2 containers..." "Cyan"
    
    try {
        docker-compose up -d
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to start containers"
        }
    }
    catch {
        Write-ColorOutput "`nFailed to start containers!" "Red"
        Write-ColorOutput "Error: $_" "Red"
        Write-ColorOutput "`nTry running: docker-compose down -v" "Yellow"
        Write-ColorOutput "Then run this script again.`n" "Yellow"
        exit 1
    }
    
    Write-ColorOutput "`n===============================================" "Green"
    Write-ColorOutput "       DHIS2 Started Successfully!" "Green"
    Write-ColorOutput "===============================================" "Green"
    
    Write-ColorOutput "`nConnection Details:" "Cyan"
    Write-ColorOutput "  URL:      http://localhost:8080" "Yellow"
    Write-ColorOutput "  Username: admin" "Yellow"
    Write-ColorOutput "  Password: district" "Yellow"
    
    Write-ColorOutput "`nFirst startup takes 3-5 minutes..." "Magenta"
    Write-ColorOutput "Watch progress: docker-compose logs -f dhis2" "Cyan"
    
    Write-ColorOutput "`nSECURITY: Change password immediately after first login!" "Red"
    
    Write-ColorOutput "`nUseful Commands:" "Cyan"
    Write-ColorOutput "  View logs:    docker-compose logs -f" "White"
    Write-ColorOutput "  Stop DHIS2:   docker-compose stop" "White"
    Write-ColorOutput "  Start DHIS2:  docker-compose start" "White"
    Write-ColorOutput "  Check status: docker ps" "White"
    
    $response = Read-Host "`nDo you want to watch the startup logs now? (Y/n)"
    
    if ($response -ne 'n' -and $response -ne 'N') {
        Write-ColorOutput "`nShowing live logs (Press Ctrl+C to exit)...`n" "Blue"
        Start-Sleep -Seconds 2
        docker-compose logs -f
    }
    else {
        Write-ColorOutput "`nInstallation started successfully!" "Green"
        Write-ColorOutput "Run 'docker-compose logs -f' anytime to watch the logs.`n" "Cyan"
    }
}

try {
    Start-Installation
}
catch {
    Write-ColorOutput "`nAn unexpected error occurred!" "Red"
    Write-ColorOutput "Error: $_" "Red"
    Write-ColorOutput "`nPlease check the error message and try again.`n" "Yellow"
    exit 1
}
