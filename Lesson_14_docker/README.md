# Домашнее задание №14
## Условие

1. Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)
2. Определите разницу между контейнером и образом. Вывод опишите в домашнем задании.
3. Ответьте на вопрос: Можно ли в контейнере собрать ядро?
4. Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.
Задание со * (звездочкой)
5. Создайте кастомные образы nginx и php, объедините их в docker-compose.
6. После запуска nginx должен показывать php info.

7. Все собранные образы должны быть в docker hub.
## Решение:

### Разницу между контейнером и образом

  - Образ это аналог образа виртуальной машины, а контейнер это экземпляр этого образа
  - Образ это как исполняемый файл, а контейнер как процесс 

### Можно ли в контейнере собрать ядро?

Можно собрать ядро, но загрузиться с него нельзя.
Вот несколько примеров:

https://github.com/tomzo/docker-kernel-ide

https://github.com/moul/docker-kernel-builder

https://www.olimex.com/forum/index.php?topic=4498.0

#### Установка Docker

- Устаналиваем пререквизиты ```yum install -y yum-utils device-mapper-persistent-data lvm2```
- Добавляем репозиторий ```yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo```
- Устанавливаем Docker и дополнительные компоненты ```yum install docker-ce docker-ce-cli containerd.io```
- Устаналиваем в автозагрузку и стартуем Docker ```systemctl enable docker; systemctl start docker```

Данный алгоритм установки взять с официального сайта Docker.

#### Установка Docker-compose

- ```curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose```
- ```chmod +x /usr/local/bin/docker-compose```
- ```docker-compose --version```

```
root@docker vagrant]docker -v
Docker version 1.13.1, build 0be3e21/1.13.1
```
1. Создаем свой кастомный образ на базе alpine
- Создаем отдельную директорию и кладем туда два файла:

  - Создаем файл [Dockerfile](/images/nginx/dockerfile)

  - Создаем файл [index.html](/images/nginx/html/index.html) с измененным содержимым (этот файл будет импортирован в наш образ при создании)

- После чего собираем наш образ командой ```docker build -t fa83afa8bbcd/myimages:nginx_v1 .```
Далее можем запустить наш контейнер командой ```docker run -d -p 1234:80 fa83afa8bbcd/myimages:nginx_v1```
Видим наш образы и наши контейнеры:
```
[root@docker test]# docker run -d -p 1234:80 fa83afa8bbcd/myimages:nginx_v1
750c2ae8a4d9f411237091665a893e7ee731575fca98497ad1833839d3f56322
[root@docker test]# docker ps
CONTAINER ID        IMAGE                       COMMAND                  CREATED             STATUS              PORTS                           NAMES
750c2ae8a4d9        fa83afa8bbcd/myimages:nginx_v1   "nginx -g 'daemon ..."   6 seconds ago       Up 5 seconds        443/tcp, 0.0.0.0:1234->80/tcp   upbeat_lamport
[root@docker test]# docker images 
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
fa83afa8bbcd/myimages    nginx_v1            3ff639c8fd5f        2 minutes ago       211 MB
```
 2. Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.

 - Ссылка на репозиторий - ```https://hub.docker.com/r/fa83afa8bbcd/myimages/tags```
 - Выполняем команду ```docker login```, и вводим логин и пароль от нашего зарегистрированного аккаунта из docker-hub:
```
[root@docker test]# docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: fa83afa8bbcd
Password: 
Login Succeeded
[root@docker test]# 
```
 - Далее делаем push ```docker push fa83afa8bbcd/myimages:nginx_v1```
```
[root@docker test]# docker push fa83afa8bbcd/myimages:nginx_v1
The push refers to a repository [docker.io/fa83afa8bbcd/myimages]
5520c4ff578f: Pushed 
3fdbaa2af63a: Pushed 
237d1e8ba415: Pushed 
cd48551ed233: Pushed 
b2d5eeeaba3a: Pushed 
nginx_v1: digest: sha256:dd1c15f689e4e0f173eb65f597408f44c2c9beff97c4a7cce80dad993921dcfd size: 1365
```
3. Создайте кастомные образы nginx и php, объедините их в docker-compose (файлы во вложении)
- Переходим туда где у нас храниться файл docker-compose.yml и выполняем:

### Задание с *

Создал два docker образа (nginx, php) и сохранил их в docker hub. 
[otus-php](https://hub.docker.com/repository/docker/fa83afa8bbcd/otus-php)
[nginx](https://hub.docker.com/repository/docker/fa83afa8bbcd/myimages)

Dockerfile данных образов расположены в каталоге images. Данные образы использовал для создания docker compose файла.
Перед запуском сборки ВМ необходимо установить плагин vagrant для docker. Для этого необходимо выполнить следующую команду в терминале

        vagrant plugin install vagrant-docker-compose
        vagrant up

После того как ВМ будет развернута в браузере необходимо ввести следующий адрес http://192.168.11.101


### Литература 
- [Docker. Начало](https://habr.com/ru/post/353238/)