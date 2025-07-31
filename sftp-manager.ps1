# SFTP Docker Server Manager
# Unified script for managing SFTP server

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "test", "copy-keys", "status", "logs", "menu")]
    [string]$Action = "menu"
)

function Show-Menu {
    Clear-Host
    Write-Host "SFTP Docker Server Manager" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    Write-Host ""
    Write-Host "1. Start Server        - Start SFTP server" -ForegroundColor Cyan
    Write-Host "2. Stop Server         - Stop server" -ForegroundColor Cyan
    Write-Host "3. Test Connection     - Test SFTP connection" -ForegroundColor Cyan
    Write-Host "4. Display Keys for Laravel - Show SSH keys content" -ForegroundColor Cyan
    Write-Host "5. Server Status       - Show server status" -ForegroundColor Cyan
    Write-Host "6. Show Logs           - Show server logs" -ForegroundColor Cyan
    Write-Host "0. Exit               - Exit" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or use: .\sftp-manager.ps1 <action>" -ForegroundColor Gray
    Write-Host "Example: .\sftp-manager.ps1 start" -ForegroundColor Gray
    Write-Host ""
}

function Start-SftpServer {
    Write-Host "Starting SFTP Docker server..." -ForegroundColor Green

    # Check Docker
    if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "Docker not found! Please install Docker Desktop." -ForegroundColor Red
        return $false
    }

    if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Host "Docker Compose not found!" -ForegroundColor Red
        return $false
    }

    # Create directories
    Write-Host "Creating directories..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path "data" | Out-Null
    New-Item -ItemType Directory -Force -Path "logs" | Out-Null

    # Check SSH keys
    if (!(Test-Path "keys/id_rsa.pub")) {
        Write-Host "Generating SSH keys..." -ForegroundColor Yellow
        
        New-Item -ItemType Directory -Force -Path "keys" | Out-Null
        try {
            ssh-keygen -t rsa -b 4096 -f "keys/id_rsa" -N "" -q
            Write-Host "SSH keys created successfully!" -ForegroundColor Green
        }
        catch {
            Write-Host "ssh-keygen is not available. Create keys manually." -ForegroundColor Yellow
            return $false
        }
    }

    # Set permissions
    Write-Host "Setting permissions..." -ForegroundColor Yellow
    if (Test-Path "keys/id_rsa") {
        icacls "keys/id_rsa" /inheritance:r /grant:r "$env:USERNAME:(R)" | Out-Null
    }

    # Start container
    Write-Host "Starting Docker container..." -ForegroundColor Yellow
    docker-compose up -d --build

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SFTP server started successfully!" -ForegroundColor Green
        Show-ServerInfo
        return $true
    } else {
        Write-Host "Startup error! Check logs: docker-compose logs" -ForegroundColor Red
        return $false
    }
}

function Stop-SftpServer {
    Write-Host "Stopping SFTP server..." -ForegroundColor Yellow
    docker-compose down
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SFTP server stopped" -ForegroundColor Green
    } else {
        Write-Host "Error stopping server" -ForegroundColor Red
    }
}

function Test-SftpConnection {
    Write-Host "Testing SFTP connection..." -ForegroundColor Green

    # Check container
    $containerStatus = docker ps --filter "name=sftp-docker-server" --format "{{.Status}}"
    
    if (-not $containerStatus) {
        Write-Host "SFTP container is not running!" -ForegroundColor Red
        Write-Host "Start server: .\sftp-manager.ps1 start" -ForegroundColor Yellow
        return $false
    }

    Write-Host "Container is running: $containerStatus" -ForegroundColor Green

    # Check keys
    if (!(Test-Path "keys/id_rsa") -or !(Test-Path "keys/id_rsa.pub")) {
        Write-Host "SSH keys not found!" -ForegroundColor Red
        return $false
    }

    Write-Host "SSH keys found" -ForegroundColor Green

    # Check port
    try {
        $connection = New-Object System.Net.Sockets.TcpClient
        $connection.Connect("localhost", 2222)
        if ($connection.Connected) {
            Write-Host "Port 2222 is accessible" -ForegroundColor Green
            $connection.Close()
        }
    } catch {
        Write-Host "Port 2222 is not accessible" -ForegroundColor Red
        return $false
    }

    Write-Host "SFTP server is working!" -ForegroundColor Green
    return $true
}

function Copy-KeysForLaravel {
    Write-Host "Displaying SSH keys for Laravel..." -ForegroundColor Green

    # Check source keys
    if (!(Test-Path "keys/id_rsa") -or !(Test-Path "keys/id_rsa.pub")) {
        Write-Host "SSH keys not found! Start server first." -ForegroundColor Red
        return $false
    }

    try {
        Write-Host ""
        Write-Host "=================== PUBLIC KEY ===================" -ForegroundColor Cyan
        Write-Host "File: keys/id_rsa.pub" -ForegroundColor Gray
        Write-Host "Copy this content for your Laravel public key file:" -ForegroundColor Yellow
        Write-Host ""
        Get-Content "keys/id_rsa.pub" | Write-Host -ForegroundColor White
        
        Write-Host ""
        Write-Host "================== PRIVATE KEY ===================" -ForegroundColor Cyan
        Write-Host "File: keys/id_rsa" -ForegroundColor Gray
        Write-Host "Copy this content for your Laravel private key file:" -ForegroundColor Yellow
        Write-Host ""
        try {
            # Try PowerShell Get-Content first
            Get-Content "keys/id_rsa" | Write-Host -ForegroundColor White
        }
        catch {
            Write-Host "Opening private key in Notepad for easy copying..." -ForegroundColor Yellow
            Start-Process notepad "keys\id_rsa"
            Write-Host "-> Notepad opened with private key content" -ForegroundColor Green
            Write-Host "-> Copy everything including BEGIN/END lines" -ForegroundColor Green
            Write-Host ""
            Write-Host "Alternative methods:" -ForegroundColor Cyan
            Write-Host "1. Run PowerShell as Administrator" -ForegroundColor Gray
            Write-Host "2. Use: cmd /c type keys\id_rsa" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Laravel Setup Instructions:" -ForegroundColor Green
        Write-Host "1. Create files in your Laravel project:" -ForegroundColor Yellow
        Write-Host "   storage/keys/id_rsa     <- Copy PRIVATE KEY content" -ForegroundColor Gray
        Write-Host "   storage/keys/id_rsa.pub <- Copy PUBLIC KEY content" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Add to Laravel .env file:" -ForegroundColor Yellow
        Write-Host "   SFTP_HOST=localhost" -ForegroundColor Gray
        Write-Host "   SFTP_PORT=2222" -ForegroundColor Gray
        Write-Host "   SFTP_USERNAME=sftpuser" -ForegroundColor Gray
        Write-Host "   SFTP_PRIVATE_KEY_PATH=storage/keys/id_rsa" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. Set proper permissions in Laravel:" -ForegroundColor Yellow
        Write-Host "   chmod 600 storage/keys/id_rsa" -ForegroundColor Gray
        Write-Host "   chmod 644 storage/keys/id_rsa.pub" -ForegroundColor Gray
        
        return $true
        
    } catch {
        Write-Host "Error reading keys: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-ServerStatus {
    Write-Host "SFTP Server Status:" -ForegroundColor Green
    Write-Host ""
    
    # Container status
    Write-Host "Docker containers:" -ForegroundColor Cyan
    docker ps --filter "name=sftp" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # Check files
    Write-Host ""
    Write-Host "File system:" -ForegroundColor Cyan
    if (Test-Path "data") {
        $files = Get-ChildItem -Path "data" -ErrorAction SilentlyContinue
        if ($files) {
            $files | Format-Table Name, Length, LastWriteTime -AutoSize
        } else {
            Write-Host "   Data directory is empty" -ForegroundColor Gray
        }
    } else {
        Write-Host "   Data directory does not exist" -ForegroundColor Gray
    }
}

function Show-ServerLogs {
    Write-Host "SFTP Server Logs:" -ForegroundColor Green
    docker-compose logs --tail=50
}

function Show-ServerInfo {
    Write-Host ""
    Write-Host "Server Information:" -ForegroundColor Cyan
    Write-Host "   Host: localhost" -ForegroundColor White
    Write-Host "   Port: 2222" -ForegroundColor White
    Write-Host "   User: sftpuser" -ForegroundColor White
    Write-Host "   Key: keys/id_rsa" -ForegroundColor White
    Write-Host ""
    Write-Host "Test commands:" -ForegroundColor Cyan
    Write-Host "   .\sftp-manager.ps1 test" -ForegroundColor Gray
    Write-Host "   sftp -P 2222 -i keys/id_rsa sftpuser@localhost" -ForegroundColor Gray
}

# Main logic
switch ($Action) {
    "start" { Start-SftpServer }
    "stop" { Stop-SftpServer }
    "test" { Test-SftpConnection }
    "copy-keys" { Copy-KeysForLaravel }
    "status" { Show-ServerStatus }
    "logs" { Show-ServerLogs }
    "menu" {
        do {
            Show-Menu
            $choice = Read-Host "Choose action (0-6)"
            
            switch ($choice) {
                "1" { Start-SftpServer; Read-Host "Press Enter to continue" }
                "2" { Stop-SftpServer; Read-Host "Press Enter to continue" }
                "3" { Test-SftpConnection; Read-Host "Press Enter to continue" }
                "4" { Copy-KeysForLaravel; Read-Host "Press Enter to continue" }
                "5" { Show-ServerStatus; Read-Host "Press Enter to continue" }
                "6" { Show-ServerLogs; Read-Host "Press Enter to continue" }
                "0" { Write-Host "Goodbye!" -ForegroundColor Green; break }
                default { Write-Host "Invalid choice" -ForegroundColor Red; Start-Sleep 1 }
            }
        } while ($choice -ne "0")
    }
}