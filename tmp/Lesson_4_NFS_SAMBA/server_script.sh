#!/bin/bash
# https://wiki.it-kb.ru/unix-linux/centos/linux-how-to-setup-nfs-server-with-share-and-nfs-client-in-centos-7-2

# проверить что монтируется гостевой образ VBoxGuestAdditions.isoесли не монтируется выполнить команды из co8.bat на хосте
#станавливаем пакеты для организации NFS-сервера

yum install nfs-utils -y
# создаем каталоги для шары и выдаем права на пользователя vagrant
mkdir -p /mnt/nfs
chown -R vagrant:vagrant /mnt/nfs/
chmod  777 /mnt/nfs
mkdir -p /mnt/nfs/upload
chown -R vagrant:vagrant /mnt/nfs/upload/
chmod  777 /mnt/nfs/upload/
# прописываем разрешение на шару (запись со всех хостов сети)
echo "/mnt/nfs    *(rw,sync)" >> /etc/exports
echo "/mnt/nfs/upload *(rw,sync)" >> /etc/exports

# Включаем автозагрузку для служб rpcbind и nfs-server, firewall:

systemctl enable rpcbind nfs-server firewalld
systemctl start rpcbind nfs-server firewalld

#настраиваем firewall
firewall-cmd --permanent --zone=public --add-service=nfs3
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --zone=public --remove-interface=eth1
firewall-cmd --zone=internal --add-interface=eth1
firewall-cmd --zone=internal --remove-service=dhcpv6-client
firewall-cmd --zone=internal --remove-service=mdns
firewall-cmd --zone=internal --remove-service=samba-client
firewall-cmd --zone=internal --add-port=111/udp
firewall-cmd --zone=internal --add-port=2049/udp
firewall-cmd --zone=internal --add-port=32769/udp
firewall-cmd --zone=internal --add-port=892/udp
firewall-cmd --zone=internal --add-port=662/udp
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --reload
# публикуем шару
exportfs -arv
# пишем тестовый файл с сервера , для проверки видимости с клиента
echo "On Server" >> /mnt/nfs/upload/file_created_on_server.text
ls /mnt/nfs/upload/
