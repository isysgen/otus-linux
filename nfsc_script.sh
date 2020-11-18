#!/bin/bash
# https://wiki.it-kb.ru/unix-linux/centos/linux-how-to-setup-nfs-server-with-share-and-nfs-client-in-centos-7-2
# проверить что монтируется гостевой образ VBoxGuestAdditions.isoесли не монтируется выполнить команды из co8.bat на хосте
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh

yum update -y
yum install nfs-utils vim net-tools -y
#Включаем и запускаем включаем службы NFS:
systemctl start rpcbind
systemctl enable rpcbind

#Создаем каталог, в который будет смонтирована шара и монтируем шару:
# раздаем права на пользователя
mkdir -p /mnt/download
chown -R vagrant:vagrant /mnt/download/
mount -t nfs 192.168.50.10:/mnt/nfs/upload /mnt/download
# Настраиваем автоматическое монтирование шары при перезагрузке системы, добавляя запись в конец файла /etc/fstab
echo "192.168.50.10:/mnt/nfs/upload /mnt/download nfs noauto,x-systemd.automount,proto=udp,vers=3 0 0" >> /etc/fstab

systemctl restart remote-fs.target
# активируем firewall на клиенте
systemctl enable rpcbind firewalld
systemctl start rpcbind firewalld

firewall-cmd --permanent --zone=public --add-service=nfs3
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload


# проверяем что каталог примонтирован
mount | grep nfs
cat /etc/fstab

# Проверим возможность записи в шару
echo "Clent Side" >> /mnt/download/file_created_on_client.text
ls /mnt/download/