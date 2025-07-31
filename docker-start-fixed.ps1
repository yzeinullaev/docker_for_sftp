# PowerShell script for running SFTP Docker server

Write-Host "Starting SFTP Docker server..." -ForegroundColor Green

# Check if Docker is available
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker not found! Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check if docker-compose is available
if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose not found!" -ForegroundColor Red
    exit 1
}

# Create necessary directories
Write-Host "Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "data" | Out-Null
New-Item -ItemType Directory -Force -Path "logs" | Out-Null

# Check SSH keys
if (!(Test-Path "keys/id_rsa.pub")) {
    Write-Host "Generating SSH keys..." -ForegroundColor Yellow
    
    # Try to use ssh-keygen
    try {
        ssh-keygen -t rsa -b 4096 -f "keys/id_rsa" -P "" -q
        Write-Host "SSH keys created successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "ssh-keygen is not available. Use existing keys or install OpenSSH." -ForegroundColor Yellow
    }
}

# Set proper access rights (Windows)
Write-Host "Setting access permissions..." -ForegroundColor Yellow
if (Test-Path "keys/id_rsa") {
    icacls "keys/id_rsa" /inheritance:r /grant:r "$env:USERNAME:(R)" | Out-Null
}

# Start container
Write-Host "Starting Docker container..." -ForegroundColor Yellow
docker-compose up -d --build

if ($LASTEXITCODE -eq 0) {
    Write-Host "SFTP server started successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Server Information:" -ForegroundColor Cyan
    Write-Host "   Host: localhost" -ForegroundColor White
    Write-Host "   Port: 2222" -ForegroundColor White
    Write-Host "   User: sftpuser" -ForegroundColor White
    Write-Host "   Key: keys/id_rsa" -ForegroundColor White
    Write-Host ""
    Write-Host "Test connection:" -ForegroundColor Cyan
    Write-Host "   sftp -P 2222 -i keys/id_rsa sftpuser@localhost" -ForegroundColor Gray
    Write-Host ""
    Write-Host "View logs:" -ForegroundColor Cyan
    Write-Host "   docker-compose logs -f" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Stop server:" -ForegroundColor Cyan
    Write-Host "   docker-compose down" -ForegroundColor Gray
} else {
    Write-Host "Startup error! Check logs: docker-compose logs" -ForegroundColor Red
}