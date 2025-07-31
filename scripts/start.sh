#!/bin/bash

# Запуск SFTP сервера
echo "Starting SFTP Server..."

# Проверка существования ключей
if [ ! -f /home/sftpuser/.ssh/authorized_keys ]; then
    echo "ERROR: authorized_keys file not found!"
    exit 1
fi

# Проверка прав доступа
chmod 600 /home/sftpuser/.ssh/authorized_keys
chmod 700 /home/sftpuser/.ssh
chown -R sftpuser:sftpuser /home/sftpuser/.ssh

# Создание необходимых директорий
mkdir -p /var/run/sshd

# Логирование
echo "SFTP Server configuration:"
echo "User: sftpuser"
echo "Port: 22"
echo "Authentication: Public Key"
echo "Chroot: /home/sftpuser"

# Запуск SSH демона
exec /usr/sbin/sshd -D