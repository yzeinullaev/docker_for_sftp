# PowerShell скрипт для тестирования SFTP подключения

Write-Host "🧪 Тестирование SFTP подключения..." -ForegroundColor Green

# Проверка запущен ли контейнер
$containerStatus = docker ps --filter "name=sftp-docker-server" --format "{{.Status}}"

if (-not $containerStatus) {
    Write-Host "❌ SFTP контейнер не запущен!" -ForegroundColor Red
    Write-Host "   Запустите сервер: .\docker-start.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Контейнер запущен: $containerStatus" -ForegroundColor Green

# Проверка наличия ключей
if (!(Test-Path "keys/id_rsa")) {
    Write-Host "❌ Приватный ключ не найден!" -ForegroundColor Red
    exit 1
}

if (!(Test-Path "keys/id_rsa.pub")) {
    Write-Host "❌ Публичный ключ не найден!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ SSH ключи найдены" -ForegroundColor Green

# Создание тестового файла
$testFile = "test-upload.txt"
$testContent = "Тестовый файл для SFTP - " + (Get-Date)
Set-Content -Path $testFile -Value $testContent
Write-Host "📄 Создан тестовый файл: $testFile" -ForegroundColor Yellow

# Проверка подключения через SFTP
Write-Host "🔗 Тестирование подключения..." -ForegroundColor Yellow

# Создание временного SFTP скрипта
$sftpScript = @"
put $testFile /upload/$testFile
ls /upload/
quit
"@

Set-Content -Path "sftp-commands.tmp" -Value $sftpScript

try {
    # Попытка подключения
    $result = sftp -P 2222 -i "keys/id_rsa" -b "sftp-commands.tmp" sftpuser@localhost 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SFTP подключение успешно!" -ForegroundColor Green
        Write-Host "📁 Содержимое директории /upload/:" -ForegroundColor Cyan
        Write-Host $result -ForegroundColor Gray
    } else {
        Write-Host "❌ Ошибка SFTP подключения!" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Ошибка: $_" -ForegroundColor Red
    Write-Host "💡 Убедитесь что установлен OpenSSH клиент" -ForegroundColor Yellow
} finally {
    # Очистка временных файлов
    if (Test-Path "sftp-commands.tmp") { Remove-Item "sftp-commands.tmp" }
    if (Test-Path $testFile) { Remove-Item $testFile }
}

Write-Host ""
Write-Host "🔍 Дополнительная диагностика:" -ForegroundColor Cyan
Write-Host "   📊 Логи контейнера: docker-compose logs" -ForegroundColor Gray
Write-Host "   🔧 Подключение к контейнеру: docker exec -it sftp-docker-server bash" -ForegroundColor Gray