# **Дисковая подсистема**

## **Homework 2**

- Добавить в Vagrantfile еще дисков.
- Собрать R0/R5/R10 на выбор.
- Прописать собранный рейд в конфигурационный файл, чтобы рейд собирался при загрузке.
- Сломать/починить raid.
- Создать GPT раздел и 5 партиций.
- Vagrantfile, который сразу собирает систему с подключенным рейдом.

## **1. Работа с Vagrant**

#vagrant -v

vagrant -v

#vagrant box list

centos/7          (virtualbox, 1905.1)


**Создан Vagrantfile.**

#vagrant up


**Далее проверим поднялась ли машина:**

#vagrant status

Current machine states:

otuslinux                 running (virtualbox)

**Все работает корректно, можно подлючиться к ней:**

#vagrant ssh

Last login: Wed Feb 12 11:20:53 2020 from 10.0.2.2
[vagrant@otuslinux ~]$ 

**Видим что все прошло корректно:**

[vagrant@otuslinux ~]$ lsscsi

[0:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sda

[3:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdb

[4:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdc

[5:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdd

[6:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sde

[7:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdf

[8:0:0:0]    disk    ATA      VBOX HARDDISK    1.0   /dev/sdg

## **2.Работа с mdadm, сборка RAID**

**Собираем из дисков RAID. Выбран RAID 5.Опция -l какого уровня RAID создавать,опция - n указывает на кол-во устройств в RAID:**

#[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
mdadm: layout defaults to left-symmetric

mdadm: layout defaults to left-symmetric

mdadm: chunk size defaults to 512K

mdadm: size set to 253952K

mdadm: Defaulting to version 1.2 metadata

mdadm: array /dev/md0 started.


**Смотрим состояние рэйда после сборки:**

#[vagrant@otuslinux ~]$ cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4]

md0 : active raid5 sdf[5] sde[3] sdd[2] sdc[1] sdb[0]

      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]
	  
unused devices: <none>	  

#[root@otuslinux ~]# mdadm -D /dev/md0

/dev/md0:

           Version : 1.2		   
     Creation Time : Wed Feb 12 11:48:38 2020	 
        Raid Level : raid5		
        Array Size : 1015808 (992.00 MiB 1040.19 MB)		
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)	 
      Raid Devices : 5	  
     Total Devices : 5 
       Persistence : Superblock is persistent
       Update Time : Wed Feb 12 11:48:45 2020
             State : clean
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       5       8       80        4      active sync   /dev/sdf
	   
**Создание конфигурационного файла mdadm.conf:**

Сначала убедимся, что информация верна:

[root@otuslinux ~]# mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf

А затем в две команды создадим файл mdadm.conf

[root@otuslinux ~]# echo "DEVICE partitions" > /etc/mdadm.conf

[root@otuslinux ~]# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf

## **3.Создать GPT раздел, пять партиций и смонтировать их на диск:**

Создаем раздел GPT на RAID[root@mdadm ~]$ parted -s /dev/md0 mklabel gpt

Создаем партиции:

[root@mdadm ~]$ parted /dev/md0 mkpart primary ext4 0% 20%
[root@mdadm ~]$ parted /dev/md0 mkpart primary ext4 20% 40%
[root@mdadm ~]$ parted /dev/md0 mkpart primary ext4 40% 60%
[root@mdadm ~]$ parted /dev/md0 mkpart primary ext4 60% 80%
[root@mdadm ~]$ parted /dev/md0 mkpart primary ext4 80% 100%

создаем ФС

[root@mdadm ~]$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

И смонтировать их по каталогам

[root@mdadm ~]$ mkdir -p /raid/part{1,2,3,4,5}

[root@mdadm ~]$ for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done
	   
## **4.Работа с mdadm, поломать/починить RAID5**

**Ломаем:**

[root@mdadm ~]$mdadm /dev/md0 --fail /dev/sde

**Проверяем:**

[root@otuslinux ~]# cat /proc/mdstat

Personalities : [raid6] [raid5] [raid4]
md0 : active raid5 sdf[5] sde[3](F) sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUU_U]

[root@otuslinux ~]# mdadm -D /dev/md0
mdadm: ARRAY line /dev/md0 has no identity information.

/dev/md0:
           Version : 1.2
		   
     Creation Time : Wed Feb 12 11:48:38 2020
        Raid Level : raid5
        Array Size : 1015808 (992.00 MiB 1040.19 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent
       Update Time : Wed Feb 12 12:09:23 2020
             State : clean, degraded
    Active Devices : 4
	Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0
            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : fa4abb4a:0a8ee1cc:25492c37:4970428f
            Events : 20

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       -       0        0        3      removed
       5       8       80        4      active sync   /dev/sdf

       3       8       64        -      faulty   /dev/sde
	   
**Видно что помечен теперь как поломанный:**


[vagrant@otuslinux ~]$ watch cat /proc/mdstat

Every 2.0s: cat /proc/mdstat 
                                                                   Wed Feb 12 12:14:22 2020
Personalities : [raid6] [raid5] [raid4]

md0 : active raid5 sdf[5] sde[3](F) sdd[2] sdc[1] sdb[0]
      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUU_U]

unused devices: <none>


**Уберем его, чтобы заменить на новый:**

[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --remove /dev/sde

[vagrant@otuslinux ~]$ sudo mdadm /dev/md0 --add /dev/sde

mdadm: added /dev/sde

[vagrant@otuslinux ~]$ cat /proc/mdstat 

Personalities : [raid6] [raid5] [raid4]

md0 : active raid5 sde[6] sdf[5] sdd[2] sdc[1] sdb[0]

      1015808 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

unused devices: <none>

## **5.Прописываем собранный рейд в конфигурационный файл, чтобы рейд собирался при загрузке.**

**Для того, чтобы быть уверенным что ОС запомнила какой RAID массив требуется создать и какие компоненты в него входят
 создадим файл mdadm.conf.
Сначала убедимся, что информация верна:**

[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose

ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=b4d3da63:dc6dd4d1:493d0a01:3bded655

   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf


**Теперь создадим mdadm.conf:**

[root@otuslinux vagrant]#echo "DEVICE partitions" > /etc/mdadm/mdadm.conf

[root@otuslinux vagrant]#mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf


**Созданный файл:**

[vagrant@otuslinux ~]$ cat /etc/mdadm/mdadm.conf

DEVICE partitions

ARRAY /dev/md0 level=raid5 num-devices=5 metadata=1.2 name=otuslinux:0 UUID=b4d3da63:dc6dd4d1:493d0a01:3bded655


**В итоге получаем следущее:**

[vagrant@otuslinux ~]$ lsblk

NAME      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT

sda         8:0    0   40G  0 disk  
└─sda1      8:1    0   40G  0 part  /

sdb         8:16   0  250M  0 disk  
└─md0       9:0    0  992M  0 raid5 

  ├─md0p1 259:0    0  196M  0 md    /raid/part1

  ├─md0p2 259:1    0  198M  0 md    /raid/part2

  ├─md0p3 259:2    0  200M  0 md    /raid/part3

  ├─md0p4 259:3    0  198M  0 md    /raid/part4

  └─md0p5 259:4    0  196M  0 md    /raid/part5

sdc         8:32   0  250M  0 disk  
└─md0       9:0    0  992M  0 raid5 

  ├─md0p1 259:0    0  196M  0 md    /raid/part1

  ├─md0p2 259:1    0  198M  0 md    /raid/part2

  ├─md0p3 259:2    0  200M  0 md    /raid/part3

  ├─md0p4 259:3    0  198M  0 md    /raid/part4

  └─md0p5 259:4    0  196M  0 md    /raid/part5

sdd         8:48   0  250M  0 disk  
└─md0       9:0    0  992M  0 raid5 

  ├─md0p1 259:0    0  196M  0 md    /raid/part1

  ├─md0p2 259:1    0  198M  0 md    /raid/part2

  ├─md0p3 259:2    0  200M  0 md    /raid/part3

  ├─md0p4 259:3    0  198M  0 md    /raid/part4

  └─md0p5 259:4    0  196M  0 md    /raid/part5

sde         8:64   0  250M  0 disk  
└─md0       9:0    0  992M  0 raid5 

  ├─md0p1 259:0    0  196M  0 md    /raid/part1

  ├─md0p2 259:1    0  198M  0 md    /raid/part2

  ├─md0p3 259:2    0  200M  0 md    /raid/part3

  ├─md0p4 259:3    0  198M  0 md    /raid/part4

  └─md0p5 259:4    0  196M  0 md    /raid/part5

sdf         8:80   0  250M  0 disk  
└─md0       9:0    0  992M  0 raid5 

  ├─md0p1 259:0    0  196M  0 md    /raid/part1

  ├─md0p2 259:1    0  198M  0 md    /raid/part2

  ├─md0p3 259:2    0  200M  0 md    /raid/part3

  ├─md0p4 259:3    0  198M  0 md    /raid/part4

  └─md0p5 259:4    0  196M  0 md    /raid/part5
    

Vagrantfile, который сразу собирает систему с подключенным рейдом приложен

