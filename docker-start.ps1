# PowerShell скрипт для запуска SFTP Docker сервера

Write-Host "🚀 Запуск SFTP Docker сервера..." -ForegroundColor Green

# Проверка наличия Docker
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker не найден! Установите Docker Desktop." -ForegroundColor Red
    exit 1
}

# Проверка наличия docker-compose
if (!(Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker Compose не найден!" -ForegroundColor Red
    exit 1
}

# Создание необходимых директорий
Write-Host "📁 Создание директорий..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "data" | Out-Null
New-Item -ItemType Directory -Force -Path "logs" | Out-Null

# Проверка SSH ключей
if (!(Test-Path "keys/id_rsa.pub")) {
    Write-Host "🔑 Генерация SSH ключей..." -ForegroundColor Yellow
    
    # Попытка использовать ssh-keygen
    try {
        ssh-keygen -t rsa -b 4096 -f "keys/id_rsa" -N "" -q
        Write-Host "✅ SSH ключи созданы!" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ ssh-keygen недоступен. Используйте существующие ключи или установите OpenSSH." -ForegroundColor Yellow
    }
}

# Установка правильных прав доступа (Windows)
Write-Host "🔒 Настройка прав доступа..." -ForegroundColor Yellow
if (Test-Path "keys/id_rsa") {
    icacls "keys/id_rsa" /inheritance:r /grant:r "$env:USERNAME:(R)" | Out-Null
}

# Запуск контейнера
Write-Host "🐳 Запуск Docker контейнера..." -ForegroundColor Yellow
docker-compose up -d --build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SFTP сервер запущен успешно!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Информация о сервере:" -ForegroundColor Cyan
    Write-Host "   🌐 Хост: localhost" -ForegroundColor White
    Write-Host "   🔌 Порт: 2222" -ForegroundColor White
    Write-Host "   👤 Пользователь: sftpuser" -ForegroundColor White
    Write-Host "   🔑 Ключ: keys/id_rsa" -ForegroundColor White
    Write-Host ""
    Write-Host "🧪 Тест подключения:" -ForegroundColor Cyan
    Write-Host "   sftp -P 2222 -i keys/id_rsa sftpuser@localhost" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📊 Просмотр логов:" -ForegroundColor Cyan
    Write-Host "   docker-compose logs -f" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🛑 Остановка сервера:" -ForegroundColor Cyan
    Write-Host "   docker-compose down" -ForegroundColor Gray
} else {
    Write-Host "❌ Ошибка запуска! Проверьте логи: docker-compose logs" -ForegroundColor Red
}