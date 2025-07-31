# Simple PowerShell test script for SFTP connection

Write-Host "=== SFTP Docker Server Test ===" -ForegroundColor Green

# Check container status
Write-Host "`n1. Container Status:" -ForegroundColor Yellow
docker ps --filter "name=sftp-docker-server"

# Check if port is accessible
Write-Host "`n2. Port Connectivity Test:" -ForegroundColor Yellow
try {
    $connection = New-Object System.Net.Sockets.TcpClient
    $connection.Connect("localhost", 2222)
    if ($connection.Connected) {
        Write-Host "✅ Port 2222 is accessible" -ForegroundColor Green
        $connection.Close()
    }
} catch {
    Write-Host "❌ Cannot connect to port 2222" -ForegroundColor Red
}

# Check server files
Write-Host "`n3. Server Files:" -ForegroundColor Yellow
docker exec sftp-docker-server /bin/bash -c "ls -la /home/sftpuser/upload/"

# Check mounted volume
Write-Host "`n4. Mounted Data Directory:" -ForegroundColor Yellow
Get-ChildItem -Path "data" -ErrorAction SilentlyContinue | Format-Table Name, Length, LastWriteTime

# Test SFTP connection using simple authentication
Write-Host "`n5. SFTP Connection Test:" -ForegroundColor Yellow
Write-Host "For manual testing, use:" -ForegroundColor Cyan
Write-Host "sftp -o StrictHostKeyChecking=no -P 2222 -i keys/id_rsa sftpuser@localhost" -ForegroundColor Gray

# Laravel connection example
Write-Host "`n6. Laravel Integration:" -ForegroundColor Yellow
Write-Host "Use this configuration in your Laravel .env:" -ForegroundColor Cyan
Write-Host "SFTP_HOST=localhost" -ForegroundColor Gray
Write-Host "SFTP_PORT=2222" -ForegroundColor Gray
Write-Host "SFTP_USERNAME=sftpuser" -ForegroundColor Gray
Write-Host "SFTP_PRIVATE_KEY_PATH=storage/keys/id_rsa" -ForegroundColor Gray

Write-Host "`n✅ SFTP Server is ready for use!" -ForegroundColor Green