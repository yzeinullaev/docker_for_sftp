FROM ubuntu:22.04

# Установка необходимых пакетов
RUN apt-get update && apt-get install -y \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Создание директории для SSH
RUN mkdir /var/run/sshd

# Создание пользователя для SFTP
RUN useradd -m -d /home/sftpuser -s /bin/bash sftpuser

# Создание директории для SFTP и установка правильных прав
RUN mkdir -p /home/sftpuser/upload
RUN chown root:root /home/sftpuser
RUN chmod 755 /home/sftpuser
RUN chown sftpuser:sftpuser /home/sftpuser/upload

# Создание директории для SSH ключей пользователя
RUN mkdir -p /home/sftpuser/.ssh
RUN chown sftpuser:sftpuser /home/sftpuser/.ssh
RUN chmod 700 /home/sftpuser/.ssh

# Копирование публичного ключа
COPY keys/id_ed25519.pub /home/sftpuser/.ssh/authorized_keys
RUN chown sftpuser:sftpuser /home/sftpuser/.ssh/authorized_keys
RUN chmod 600 /home/sftpuser/.ssh/authorized_keys

# Копирование конфигурации SSH
COPY config/sshd_config /etc/ssh/sshd_config

# Генерация host ключей
RUN ssh-keygen -A

# Открытие порта
EXPOSE 22

# Запуск SSH демона напрямую
CMD ["/usr/sbin/sshd", "-D"]