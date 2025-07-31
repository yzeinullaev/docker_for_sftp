# Simple script to copy SSH keys for Laravel

Write-Host "Copying SSH keys for Laravel..." -ForegroundColor Green

# Create Laravel keys directory
$dir = "laravel-keys"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

# Copy keys
Copy-Item "keys/id_rsa" "$dir/id_rsa" -Force
Copy-Item "keys/id_rsa.pub" "$dir/id_rsa.pub" -Force

Write-Host "Keys copied to $dir directory" -ForegroundColor Green
Write-Host "Copy these files to your Laravel project:" -ForegroundColor Yellow
Write-Host "  laravel-keys/id_rsa -> storage/keys/id_rsa" -ForegroundColor Gray
Write-Host "  laravel-keys/id_rsa.pub -> storage/keys/id_rsa.pub" -ForegroundColor Gray

# Show public key content
Write-Host "`nPublic key content:" -ForegroundColor Cyan
Get-Content "keys/id_rsa.pub"