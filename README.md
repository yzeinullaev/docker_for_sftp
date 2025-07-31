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
sftp -P 2222 -i keys/id_rsa sftpuser@localhost
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
│   ├── id_rsa              # Приватный ключ (для подключений)
│   ├── id_rsa.pub          # Публичный ключ
│   └── id_rsa_readable     # Приватный ключ (для просмотра)
├── laravel-keys/
│   └── id_rsa.pub          # Копия для Laravel
├── data/                   # SFTP файлы (монтируется в контейнер)
└── logs/                   # Логи сервера
```

## Ключи

- `keys/id_rsa` - для подключений
- `keys/id_rsa_readable` - для просмотра
- `keys/id_rsa.pub` - публичный

Приватные ключи не попадают в Git.