#!/bin/bash
#Обновляем систему
sudo yum -y update
#Устанавливаем mdadm
sudo yum -y install mdadm
#Создаем raid 10 из 6 дисков
sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}  # занулим на всякий случай суперблоки
sudo mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}

# для того, чтобы быть уверенным, что ОС запомнила какой RAID массив
# требуется создать и какие компоненты в него входят создадим файл mdadm.conf
sudo mkdir /etc/mdadm/
echo "DEVICE partitions" | sudo tee -a  /etc/mdadm/mdadm.conf
sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' | sudo tee -a /etc/mdadm/mdadm.conf

# создаем таблицу разделов GPT на RAID
sudo parted -s /dev/md0 mklabel gpt
sudo parted /dev/md0 mkpart primary ext4 0% 20%
sudo parted /dev/md0 mkpart primary ext4 20% 40%
sudo parted /dev/md0 mkpart primary ext4 40% 60%
sudo parted /dev/md0 mkpart primary ext4 60% 80%
sudo parted /dev/md0 mkpart primary ext4 80% 100%

# делаем ФС на каждой из этих партиций
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

# монтируем разделы в директории и заполняем fstab
sudo mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do
    mount /dev/md0p$i /raid/part$i
    echo "/dev/md0p$i     /raid/part$i     ext4    defaults    0   0" >> /etc/fstab
done





#Update system
#Install mdadm
#reates a raid 10 of six disks
# для того, чтобы быть уверенным, что ОС запомнила какой RAID массив
# требуется создать и какие компоненты в него входят создадим файл mdadm.conf
# создаем таблицу разделов GPT на RAID
# делаем ФС на каждой из этих партиций
# монтируем разделы в директории и заполняем fstab