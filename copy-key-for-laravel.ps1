# Скрипт для безопасного копирования SSH ключа для Laravel

Write-Host "🔑 Копирование SSH ключа для Laravel..." -ForegroundColor Green

# Создание директории для Laravel ключей
$laravelKeysDir = "laravel-keys"
if (!(Test-Path $laravelKeysDir)) {
    New-Item -ItemType Directory -Path $laravelKeysDir | Out-Null
    Write-Host "✅ Создана директория: $laravelKeysDir" -ForegroundColor Green
}

# Попытка копирования с установкой новых прав
try {
    # Копирование приватного ключа
    Copy-Item "keys/id_rsa" "$laravelKeysDir/id_rsa" -Force
    Write-Host "✅ Приватный ключ скопирован" -ForegroundColor Green
    
    # Копирование публичного ключа  
    Copy-Item "keys/id_rsa.pub" "$laravelKeysDir/id_rsa.pub" -Force
    Write-Host "✅ Публичный ключ скопирован" -ForegroundColor Green
    
    # Установка читаемых прав для Laravel
    $acl = Get-Acl "$laravelKeysDir/id_rsa"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($env:USERNAME, "Read", "Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl "$laravelKeysDir/id_rsa" $acl
    
    Write-Host "`n📁 Ключи готовы для Laravel в директории: $laravelKeysDir" -ForegroundColor Cyan
    Write-Host "📋 Скопируйте эти файлы в ваш Laravel проект:" -ForegroundColor Yellow
    Write-Host "   - Скопируйте laravel-keys/id_rsa в storage/keys/id_rsa" -ForegroundColor Gray
    Write-Host "   - Скопируйте laravel-keys/id_rsa.pub в storage/keys/id_rsa.pub" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Ошибка копирования: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Попробуйте запустить PowerShell от имени администратора" -ForegroundColor Yellow
}

# Показать содержимое публичного ключа (он не защищен)
Write-Host "`n🔓 Публичный ключ (можно безопасно просматривать):" -ForegroundColor Cyan
try {
    Get-Content "keys/id_rsa.pub"
} catch {
    Write-Host "Не удалось прочитать публичный ключ" -ForegroundColor Red
}

Write-Host "`n✅ Готово! Используйте ключи из директории laravel-keys/" -ForegroundColor Green