# SFTP Docker Server

Этот проект создает Docker-контейнер с SFTP сервером, настроенным для аутентификации через SSH ключи.

## 🚀 Быстрый старт

### 1. Клонирование и запуск

```bash
# Клонируйте репозиторий
git clone <your-repo-url>
cd SFTPDocker

# Запуск Docker контейнера
docker-compose up -d --build
```

### 2. Проверка подключения

```bash
# Тестовое подключение через SFTP
sftp -P 2222 -i keys/id_rsa sftpuser@localhost
```

## 📁 Структура проекта

```
SFTPDocker/
├── docker-compose.yml      # Docker Compose конфигурация
├── Dockerfile             # Docker образ для SFTP сервера
├── config/
│   └── sshd_config        # Конфигурация SSH сервера
├── scripts/
│   └── start.sh           # Стартовый скрипт контейнера
├── keys/
│   ├── id_rsa             # Приватный ключ
│   └── id_rsa.pub         # Публичный ключ
├── data/                  # Директория для файлов (монтируется в контейнер)
├── logs/                  # Логи сервера
└── laravel-sftp-example.php # Пример использования в Laravel
```

## ⚙️ Конфигурация

### SFTP сервер
- **Порт**: 2222 (маппится на 22 внутри контейнера)
- **Пользователь**: sftpuser
- **Аутентификация**: Только через SSH ключи (пароли отключены)
- **Chroot**: /home/sftpuser (пользователь ограничен этой директорией)
- **Загрузки**: /home/sftpuser/upload

### Docker контейнер
- **Базовый образ**: Ubuntu 22.04
- **Открытые порты**: 2222:22
- **Примонтированные директории**:
  - `./data` → `/home/sftpuser/upload`
  - `./logs` → `/var/log`

## 🔐 Настройка ключей

### Генерация новых ключей (опционально)

```bash
# В Windows PowerShell или Linux/Mac terminal
ssh-keygen -t rsa -b 4096 -f keys/id_rsa -N ""
```

### Добавление собственного публичного ключа

1. Замените содержимое `keys/id_rsa.pub` на ваш публичный ключ
2. Пересоберите контейнер:
```bash
docker-compose down
docker-compose up -d --build
```

## 💻 Использование с Laravel

### 1. Установка зависимостей

```bash
composer require phpseclib/phpseclib
```

### 2. Копирование ключей

```bash
# Скопируйте приватный ключ в Laravel проект
cp keys/id_rsa /path/to/laravel/storage/keys/
```

### 3. Использование

См. файл `laravel-sftp-example.php` для полного примера интеграции.

```php
$sftpService = new SFTPService();
$sftpService->connect();
$sftpService->uploadFile('/local/path/file.txt', '/upload/file.txt');
```

## 🛠️ Команды Docker

```bash
# Запуск контейнера
docker-compose up -d

# Остановка контейнера
docker-compose down

# Пересборка образа
docker-compose up -d --build

# Просмотр логов
docker-compose logs -f

# Подключение к контейнеру
docker exec -it sftp-docker-server bash
```

## 📝 Логи и отладка

```bash
# Просмотр логов SFTP сервера
docker-compose logs sftp-server

# Логи SSH демона внутри контейнера
docker exec sftp-docker-server tail -f /var/log/auth.log
```

## 🔍 Тестирование подключения

### Через командную строку

```bash
# SFTP подключение
sftp -P 2222 -i keys/id_rsa sftpuser@localhost

# SCP копирование
scp -P 2222 -i keys/id_rsa localfile.txt sftpuser@localhost:/upload/
```

### Через Laravel

```bash
# Запуск тестовой команды
php artisan sftp:test
```

## 🚨 Безопасность

- ✅ Аутентификация только по ключам
- ✅ Отключена аутентификация по паролю
- ✅ Chroot jail для пользователя
- ✅ Ограничение команд только SFTP
- ✅ Отключен TCP forwarding
- ✅ Отключен X11 forwarding

## 🔧 Устранение неполадок

### Контейнер не запускается
```bash
# Проверка ошибок
docker-compose logs

# Проверка статуса
docker-compose ps
```

### Проблемы с ключами
```bash
# Проверка прав доступа к ключам
ls -la keys/

# Права должны быть 600 для приватного ключа
chmod 600 keys/id_rsa
```

### Ошибки подключения
```bash
# Подключение с отладкой
sftp -v -P 2222 -i keys/id_rsa sftpuser@localhost

# Проверка логов контейнера
docker exec sftp-docker-server tail -f /var/log/auth.log
```

## 📞 Поддержка

При возникновении проблем:

1. Проверьте логи: `docker-compose logs`
2. Убедитесь что порт 2222 свободен: `netstat -an | grep 2222`
3. Проверьте права доступа к ключам
4. Убедитесь что Docker запущен и работает

## 📄 Лицензия

MIT License