# **Домашнее задание №7: Инициализация системы. Systemd и SysV**

## **Задание:**

	- **Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig**
	- **Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться**
	- **Дополнить юнит-файл apache httpd возможностьб запустить несколько инстансов сервера с разными конфигами**



### **Ход выполнения:**
**Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова. Файл и слово должны задаваться в /etc/sysconfig**

### Создадим файл с конфигурацией для сервиса в директории /etc/sysconfig - из неё сервис будет брать необходимые переменные 
``` 
touch /etc/sysconfig/watchlog
cat /etc/sysconfig/watchlog
      # Configuration file for my watchdog service
      # Place it to /etc/sysconfig
      # File and word in that file that we will be monit
      WORD="ALERT"
      LOG=/var/log/watchlog.log
```    
### Создадим /var/log/watchlog.log с произвольным содержимым + ключевое слово ‘ALERT’
```
      echo `uname -r` `date & who` 'HOMEWORK' 'ALERT' `id` > /var/log/watchlog.log
```
### Создадим скрипт 
```    
	#!/bin/bash
    WORD=$1
    LOG=$2
    DATE=`date`
    if grep $WORD $LOG &> /dev/null
      then
    logger "$DATE: I found word, Master!"
    else
    exit 0
    fi
```   
  - *Команда logger отправляет лог в системный журнал
   
### Создадим юнит для сервиса 
```
nano /etc/systemd/system/watchlog.service
```
```
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```
   
### Создадим юнит для таймера 
```
nano /etc/systemd/system/watchlog.timer
```
```
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
```   
   ### Затем достаточно только стартануть timer:
```
   systemctl start watchlog.timer
```
#### Проверяем результат:
```
[root@bash vagrant]# tail -f /var/log/messages
Mar  4 14:06:03 bash systemd: Reloading.
Mar  4 14:06:08 bash systemd: Starting My watchlog service...
Mar  4 14:06:08 bash root: Wed Mar  4 14:06:08 UTC 2020: I found word, Master!
Mar  4 14:06:08 bash systemd: Started My watchlog service.
Mar  4 14:06:42 bash systemd: Starting My watchlog service...
Mar  4 14:06:42 bash root: Wed Mar  4 14:06:42 UTC 2020: I found word, Master!
Mar  4 14:06:42 bash systemd: Started My watchlog service.
```
-  **Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться**
    
    ### Устанавливаем spawn-fcgi и необходимые для него пакеты:
    ```
    yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
    ```
    ### Раскомментируем строки с переменными в /etc/sysconfig/spawn-fcgi и приведем к виду
```    
cat /etc/sysconfig/spawn-fcgi 
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"
```
    
    ### Создадим init файл /etc/systemd/system/spawn-fcgi.service
```
cat /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
 ```   
### Убеждаемся, что все успешно работает:
```
systemctl start spawn-fcgi
```
```
[root@bash vagrant]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-03-04 14:31:57 UTC; 8s ago
 Main PID: 8070 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─8070 /usr/bin/php-cgi
           ├─8071 /usr/bin/php-cgi
           ├─8072 /usr/bin/php-cgi
           ├─8073 /usr/bin/php-cgi
           ├─8074 /usr/bin/php-cgi
           ├─8075 /usr/bin/php-cgi
           ├─8076 /usr/bin/php-cgi
           ├─8077 /usr/bin/php-cgi
           ├─8078 /usr/bin/php-cgi
           ├─8079 /usr/bin/php-cgi
           ├─8080 /usr/bin/php-cgi
           ├─8081 /usr/bin/php-cgi
           ├─8082 /usr/bin/php-cgi
           ├─8083 /usr/bin/php-cgi
           ├─8084 /usr/bin/php-cgi
           ├─8085 /usr/bin/php-cgi
           ├─8086 /usr/bin/php-cgi
           ├─8087 /usr/bin/php-cgi
           ├─8088 /usr/bin/php-cgi
           ├─8089 /usr/bin/php-cgi
           ├─8090 /usr/bin/php-cgi
           ├─8091 /usr/bin/php-cgi
           ├─8092 /usr/bin/php-cgi
           ├─8093 /usr/bin/php-cgi
           ├─8094 /usr/bin/php-cgi
           ├─8095 /usr/bin/php-cgi
           ├─8096 /usr/bin/php-cgi
           ├─8097 /usr/bin/php-cgi
           ├─8098 /usr/bin/php-cgi
           ├─8099 /usr/bin/php-cgi
           ├─8100 /usr/bin/php-cgi
           ├─8101 /usr/bin/php-cgi
           └─8102 /usr/bin/php-cgi
```                                                                                     
 - **Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами**
    
### Для запуска нескольких экземпляров сервиса будем использовать шаблон httpd@ в конфигурации файла окружения:
```
nano /etc/systemd/system/httpd@.service
```  
### Создадим два файла окружения в /etc/sysconfig, в которых задаются опции для запуска веб-сервера с необходимыми конфигурационными файлами:
    ```
    # /etc/sysconfig/httpd-first
    OPTIONS=-f conf/first.conf
    # /etc/sysconfig/httpd-second
    OPTIONS=-f conf/second.conf
    ```
### Создадим два файла конфигурации в директории /etc/httpd/conf:

    ```
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
    cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/second.conf
    ```
### Отредактируем файл конфигурации *second.conf* для исключения пересечения по портам и PidFiles.
    ```
    PidFile /var/run/httpd-second.pid
    Listen 8080
    ```
*Для удачного запуска, в конфигурационных файлах должны быть указаны уникальные для каждого экземпляра опции Listen и PidFile.
    
 ### Запускаем и проверяем:
```
 systemctl start httpd@first
 
 systemctl start httpd@second  
```
 ### Проверить можно несколькими способами, например посмотреть какие порты слушаются:
``` 
ss -tnulp | grep httpd
tcp    LISTEN     0      128    [::]:8080               [::]:*                   users:(("httpd",pid=8276,fd=4),("httpd",pid=8275,fd=4),("httpd",pid=8274,fd=4),("httpd",pid=8273,fd=4),("httpd",pid=8272,fd=4),("httpd",pid=8271,fd=4),("httpd",pid=8270,fd=4))
tcp    LISTEN     0      128    [::]:80                 [::]:*                   users:(("httpd",pid=8263,fd=4),("httpd",pid=8262,fd=4),("httpd",pid=8261,fd=4),("httpd",pid=8260,fd=4),("httpd",pid=8259,fd=4),("httpd",pid=8258,fd=4),("httpd",pid=8257,fd=4))
```
 ### статус cервиса: 
 
 ```
 [root@bash vagrant]# systemctl status httpd@*
● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-03-04 14:59:17 UTC; 5min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 8270 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─8270 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─8271 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─8272 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─8273 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─8274 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─8275 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─8276 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

Mar 04 14:59:17 bash systemd[1]: Starting The Apache HTTP Server...
Mar 04 14:59:17 bash httpd[8270]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' d...this message
Mar 04 14:59:17 bash systemd[1]: Started The Apache HTTP Server.

● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2020-03-04 14:59:11 UTC; 5min ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 8257 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─8257 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─8258 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─8259 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─8260 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─8261 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─8262 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─8263 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

Mar 04 14:59:11 bash systemd[1]: Starting The Apache HTTP Server...
Mar 04 14:59:11 bash httpd[8257]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' d...this message
Mar 04 14:59:11 bash systemd[1]: Started The Apache HTTP Server.
Hint: Some lines were ellipsized, use -l to show in full.
```
