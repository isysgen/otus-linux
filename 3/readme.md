## Уменьшить том под / до 8G
Устанавливаем xfsdump он будет необходим для снятия копии / тома.
```
yum install xfsdump -y

[root@lvm ~]# lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk
├─sda1                    8:1    0    1M  0 part
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part
  ├─VolGroup00-LogVol00 253:0    0 37.5G  0 lvm  /
  └─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
sdb                       8:16   0   10G  0 disk
sdc                       8:32   0    2G  0 disk
sdd                       8:48   0    1G  0 disk
sde                       8:64   0    1G  0 disk

[root@lvm ~]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[root@lvm ~]# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created
[root@lvm ~]# lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.
[root@lvm ~]# mkfs.xfs /dev/vg_root/lv_root
meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=639744 blks
...
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm ~]# mount /dev/vg_root/lv_root /mnt
```
## **Дампим root**
```
[root@lvm ~]#  xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
...
xfsrestore: Restore Status: SUCCESS

[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]#  chroot /mnt/ grub2-mkconfig -o /boot/grub2/grub.cfg
```
## **Обновим загрузчик и данные о рут-волюм**
```
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
Изменим /boot/grub2/grub.cfg. Заменим rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root
Выходим из chroot, перезагружаемся. Проверяем
```
[vagrant@lvm ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0   40G  0 disk
├─sda1                    8:1    0    1M  0 part
├─sda2                    8:2    0    1G  0 part /boot
└─sda3                    8:3    0   39G  0 part
  ├─VolGroup00-LogVol01 253:1    0  1.5G  0 lvm  [SWAP]
  └─VolGroup00-LogVol00 253:2    0 37.5G  0 lvm
sdb                       8:16   0   10G  0 disk
└─vg_root-lv_root       253:0    0   10G  0 lvm  /
sdc                       8:32   0    2G  0 disk
sdd                       8:48   0    1G  0 disk
sde                       8:64   0    1G  0 disk
```
Рут в нужном месте. Приступаем к изменению раздела /dev/sda1. Посколько, /dev/sda1 поднят как партиция, то форматируем диск и создадим LVM
```
[root@lvm ~]# lvremove /dev/VolGroup00/LogVol00
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
  Logical volume "LogVol00" successfully removed
[root@lvm ~]#  lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  Logical volume "LogVol00" created.
[root@lvm ~]# mkfs.xfs /dev/VolGroup00/LogVol00
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm ~]# mount /dev/VolGroup00/LogVol00 /mnt 
[root@lvm ~]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
...
xfsrestore: Restore Status: SUCCESS
[root@lvm ~]#  for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
## **Зазеркалируем /var, заранее его почистив**
```
[root@lvm boot]# pvcreate /dev/sdc /dev/sdd
[root@lvm boot]# vgcreate vg_var /dev/sd{c,d}
[root@lvm boot]# lvcreate -L 950M -m1 -n lv_var vg_var
[root@lvm boot]# mkfs.ext4 /dev/vg_var/lv_var
[root@lvm boot]# mount /dev/vg_var/lv_var /mnt
[root@lvm boot]# cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/
[root@lvm boot]# mkdir /tmp/oldvar && rm -rf /var/* 
[root@lvm boot]# umount /mnt
[root@lvm boot]# mount /dev/vg_var/lv_var /var
[root@lvm var]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
```
Перезагружаемся и продолжаем
```
[vagrant@lvm ~]$ lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk
├─sda1                     8:1    0    1M  0 part
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1.5G  0 lvm  [SWAP]
sdb                        8:16   0   10G  0 disk
└─vg_root-lv_root        253:3    0   10G  0 lvm
sdc                        8:32   0    2G  0 disk
├─vg_var-lv_var_rmeta_0  253:2    0    4M  0 lvm
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:4    0  952M  0 lvm
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
sdd                        8:48   0    1G  0 disk
├─vg_var-lv_var_rmeta_1  253:5    0    4M  0 lvm
│ └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:6    0  952M  0 lvm
  └─vg_var-lv_var        253:7    0  952M  0 lvm  /var
sde                        8:64   0    1G  0 disk

[root@lvm ~]# lvremove /dev/vg_root/lv_root
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed
[root@lvm ~]# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed
[root@lvm ~]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
[root@lvm ~]# lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
  Logical volume "LogVol_Home" created.
[root@lvm ~]# mkfs.xfs /dev/VolGroup00/LogVol_Home
meta-data=/dev/VolGroup00/LogVol_Home isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@lvm ~]# mount /dev/VolGroup00/LogVol_Home /mnt/
[root@lvm ~]# cp -aR /home/* /mnt/ 
[root@lvm ~]# rm -rf /home/*
[root@lvm ~]# umount /mnt
[root@lvm ~]# mount /dev/VolGroup00/LogVol_Home /home/
[root@lvm ~]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
[root@lvm ~]# df -Th
Filesystem                         Type      Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00    xfs       8.0G  632M  7.4G   8% /
devtmpfs                           devtmpfs  110M     0  110M   0% /dev
tmpfs                              tmpfs     118M     0  118M   0% /dev/shm
tmpfs                              tmpfs     118M  4.5M  114M   4% /run
tmpfs                              tmpfs     118M     0  118M   0% /sys/fs/cgroup
/dev/sda2                          xfs      1014M   61M  954M   6% /boot
/dev/mapper/vg_var-lv_var          ext4      922M  135M  723M  16% /var
/dev/mapper/VolGroup00-LogVol_Home xfs       2.0G   33M  2.0G   2% /home
```
## **Сгенерируем файлы в /home/:**
```
[root@lvm ~]# touch /home/file{1..20}
[root@lvm ~]# lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
  Rounding up size to full physical extent 128,00 MiB
  Logical volume "home_snap" created.
[root@lvm ~]# rm -f /home/file{11..20}
[root@lvm ~]# umount -f /home
```
Восстановим и проверим
```
[root@lvm ~]# lvconvert --merge /dev/VolGroup00/home_snap
[root@lvm ~]# mount /home
[root@lvm ~]# ll /home/
total 0
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file1
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file10
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file11
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file12
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file13
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file14
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file15
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file16
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file17
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file18
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file19
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file2
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file20
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file3
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file4
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file5
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file6
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file7
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file8
-rw-r--r--. 1 root    root     0 Feb 26 10:05 file9
drwx------. 3 vagrant vagrant 74 May 12  2018 vagrant