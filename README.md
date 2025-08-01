# SFTP Docker Server

Docker-контейнер с SFTP сервером на SSH ключах.

## Быстрый старт

```powershell
# Запуск сервера
.\sftp-manager.ps1 start

# Просмотр ключей
.\sftp-manager.ps1 copy-keys

# Тестирование
.\sftp-manager.ps1 test
```

## Команды

```powershell
.\sftp-manager.ps1 start        # Запуск
.\sftp-manager.ps1 stop         # Остановка  
.\sftp-manager.ps1 test         # Тест
.\sftp-manager.ps1 copy-keys    # Показать ключи
.\sftp-manager.ps1 status       # Статус
.\sftp-manager.ps1 logs         # Логи
```

## Подключение

```bash
sftp -P 2222 -i keys/id_ed25519 sftpuser@localhost
```

## Настройки

- **Порт**: 2222
- **Пользователь**: sftpuser
- **Данные**: папка `data/`

## Структура файлов

```
SFTPDocker/
├── sftp-manager.ps1         # Главный скрипт управления
├── docker-compose.yml       # Конфигурация Docker
├── Dockerfile              # Сборка образа
├── README.md               # Документация
├── .gitignore              # Исключения Git
├── config/
│   └── sshd_config         # Настройки SSH
├── keys/
│   ├── id_ed25519              # Приватный ключ ED25519 (для подключений)
│   ├── id_ed25519.pub          # Публичный ключ ED25519
│   └── id_ed25519_readable     # Приватный ключ (для просмотра)
├── laravel-keys/
│   └── id_ed25519.pub          # Копия для Laravel
├── data/                   # SFTP файлы (монтируется в контейнер)
└── logs/                   # Логи сервера
```

## Ключи

Используются более безопасные ED25519 ключи:

- `keys/id_ed25519` - приватный ключ для подключений
- `keys/id_ed25519_readable` - копия для просмотра в консоли
- `keys/id_ed25519.pub` - публичный ключ

Приватные ключи не попадают в Git.