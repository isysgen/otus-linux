# **Домашняя робота №1**

Установить и познакомится познакомиться с такими инструментами, как `Vagrant` и `Packer`, получить базовые навыки работы с системами контроля версий (`Github`). Получить навыки создания кастомных образов виртуальных машин и основам их распространения через репозиторий `Vagrant Cloud`. 
Так же возможно навыки по обновлению ядра системы из репозитория.

Для выполнения работы были устьановлены следующие инструменты:

- **VirtualBox** - среда виртуализации, позволяет создавать и выполнять виртуальные машины;
- **Vagrant** - ПО для создания и конфигурирования виртуальной среды. В данном случае в качестве среды виртуализации используется *VirtualBox*;
- **Packer** - ПО для создания образов виртуальных машин;
- **Git** - система контроля версий

А так же аккаунты:

- **GitHub** - git@github.com:isysgen/otus-linux.git
- **Vagrant Cloud** - https://app.vagrantup.com/isysgen/boxes/centos-7-5

---
# **Установка ПО**

### **Vagrant**

Переходим на https://www.vagrantup.com/downloads.html выбираем соответствующую версию. Копируем ссылку и в консоли выполняем:

```
curl -O https://releases.hashicorp.com/vagrant/2.2.6/vagrant_2.2.6_x86_64.deb && \
sudo dpkg -i vagrant_2.2.6_x86_64.deb
```

После успешного окончания будет установлен Vagrant.

### **Packer**
Переходим на https://www.packer.io/downloads.html выбираем соответствующую версию. Копируем ссылку и в консоли выполняем:

```
curl https://releases.hashicorp.com/packer/1.4.4/packer_1.4.4_linux_amd64.zip | \
sudo gzip -d > /usr/local/bin/packer && \
sudo chmod +x /usr/local/bin/packer
```
После успешного окончания будет установлен Packer.


### **Git**

После установки необходимо 
```
git config --global user.name "Your Name"
git config --global user.email "your_email@whatever.com"
```

Создать репозиторий
```
git init 
git add Vagrantfile
```
дальше проверям что могу это опубликовать
```
$ git push --set-upstream isysgen master
To https://github.com/isysgen/otus-linux.git
 ! [rejected]        master -> master (fetch first)
error: failed to push some refs to 'https://github.com/isysgen/otus-linux.git'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```
воспользовался десктопной утилитой с консолью продолжу разбиратьсмя позже.
---

# **Kernel update**

### **Клонирование и запуск**

Для запуска рабочего виртуального окружения необходимо зайти через браузер в GitHub под своей учетной записью и выполнить `fork` данного репозитория: https://github.com/dmitry-lyutenko/manual_kernel_update

После этого данный репозиторий необходимо склонировать к себе на рабочую машину. 
Для этого воспользуемся ранее установленным приложением `git`
```
git clone git@github.com:isysgen/manual_kernel_update.git
```
В текущей директории появится папка с именем репозитория. `manual_kernel_update`. 

Здесь:
- `manual` - директория с данным руководством
- `packer` - директория со скриптами для `packer`'а
- `Vagrantfile` - файл описывающий виртуальную инфраструктуру для `Vagrant`

Запустим виртуальную машину и залогинимся:
```
vagrant up
...
==> kernel-update: Importing base box 'centos/7'...
...
==> kernel-update: Booting VM...
...
==> kernel-update: Setting hostname...

vagrant ssh
[vagrant@kernel-update ~]$ uname -r
3.10.0-957.12.2.el7.x86_64
```
Теперь приступим к обновлению ядра.

### **kernel update**

Подключаем репозиторий, откуда возьмем необходимую версию ядра.
```
sudo yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
```
```
yum list kernel-ml* для поиска подходящих ядер
```
```
[vagrant@kernel-update ~]$ yum list kernel-ml*
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.sale-dedic.com
 * elrepo: mirrors.nav.ro
 * extras: mirror.sale-dedic.com
 * updates: mirror.sale-dedic.com
base                                                                                                                                               | 3.6 kB  00:00:00
elrepo                                                                                                                                             | 2.9 kB  00:00:00
extras                                                                                                                                             | 2.9 kB  00:00:00
updates                                                                                                                                            | 2.9 kB  00:00:00
(1/5): base/7/x86_64/group_gz                                                                                                                      | 165 kB  00:00:00
(2/5): extras/7/x86_64/primary_db                                                                                                                  | 159 kB  00:00:00
(3/5): base/7/x86_64/primary_db                                                                                                                    | 6.0 MB  00:00:01
(4/5): updates/7/x86_64/primary_db                                                                                                                 | 5.9 MB  00:00:01
(5/5): elrepo/primary_db                                                                                                                           | 438 kB  00:00:01
Error: No matching Packages to list
[vagrant@kernel-update ~]$ yum list kernel*
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.sale-dedic.com
 * elrepo: mirrors.nav.ro
 * extras: mirror.sale-dedic.com
 * updates: mirror.sale-dedic.com
Installed Packages
kernel.x86_64                                                  3.10.0-957.12.2.el7                               @koji-override-1
kernel-tools.x86_64                                            3.10.0-957.12.2.el7                               @koji-override-1
kernel-tools-libs.x86_64                                       3.10.0-957.12.2.el7                               @koji-override-1
Available Packages
kernel.x86_64                                                  3.10.0-1062.9.1.el7                               updates
kernel-abi-whitelists.noarch                                   3.10.0-1062.9.1.el7                               updates
kernel-debug.x86_64                                            3.10.0-1062.9.1.el7                               updates
kernel-debug-devel.x86_64                                      3.10.0-1062.9.1.el7                               updates
kernel-devel.x86_64                                            3.10.0-1062.9.1.el7                               updates
kernel-doc.noarch                                              3.10.0-1062.9.1.el7                               updates
kernel-headers.x86_64                                          3.10.0-1062.9.1.el7                               updates
kernel-tools.x86_64                                            3.10.0-1062.9.1.el7                               updates
kernel-tools-libs.x86_64                                       3.10.0-1062.9.1.el7                               updates
kernel-tools-libs-devel.x86_64                                 3.10.0-1062.9.1.el7                               updates
```
как видим в выводе нет обновленных ядер
для того что бы это поправить необходимо поравить 
```
sudo nano /etc/yum.repos.d/elrepo.repo
```
и во вкладке [elrepo-kernel] установить enabled=1 после этого повторяем поис и видим новые ядра
```
[vagrant@kernel-update ~]$ yum list kernel*
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.sale-dedic.com
 * elrepo: mirrors.nav.ro
 * elrepo-kernel: mirrors.nav.ro
 * extras: mirror.sale-dedic.com
 * updates: mirror.sale-dedic.com
Installed Packages
kernel.x86_64                                                   3.10.0-957.12.2.el7                                 @koji-override-1
kernel-tools.x86_64                                             3.10.0-957.12.2.el7                                 @koji-override-1
kernel-tools-libs.x86_64                                        3.10.0-957.12.2.el7                                 @koji-override-1
Available Packages
kernel.x86_64                                                   3.10.0-1062.9.1.el7                                 updates
kernel-abi-whitelists.noarch                                    3.10.0-1062.9.1.el7                                 updates
kernel-debug.x86_64                                             3.10.0-1062.9.1.el7                                 updates
kernel-debug-devel.x86_64                                       3.10.0-1062.9.1.el7                                 updates
kernel-devel.x86_64                                             3.10.0-1062.9.1.el7                                 updates
kernel-doc.noarch                                               3.10.0-1062.9.1.el7                                 updates
kernel-headers.x86_64                                           3.10.0-1062.9.1.el7                                 updates
kernel-lt.x86_64                                                4.4.212-1.el7.elrepo                                elrepo-kernel
kernel-lt-devel.x86_64                                          4.4.212-1.el7.elrepo                                elrepo-kernel
kernel-lt-doc.noarch                                            4.4.212-1.el7.elrepo                                elrepo-kernel
kernel-lt-headers.x86_64                                        4.4.212-1.el7.elrepo                                elrepo-kernel
kernel-lt-tools.x86_64                                          4.4.212-1.el7.elrepo                                elrepo-kernel
kernel-lt-tools-libs.x86_64                                     4.4.212-1.el7.elrepo                                elrepo-kernel
kernel-lt-tools-libs-devel.x86_64                               4.4.212-1.el7.elrepo                                elrepo-kernel
kernel-ml.x86_64                                                5.5.1-1.el7.elrepo                                  elrepo-kernel
kernel-ml-devel.x86_64                                          5.5.1-1.el7.elrepo                                  elrepo-kernel
kernel-ml-doc.noarch                                            5.5.1-1.el7.elrepo                                  elrepo-kernel
kernel-ml-headers.x86_64                                        5.5.1-1.el7.elrepo                                  elrepo-kernel
kernel-ml-tools.x86_64                                          5.5.1-1.el7.elrepo                                  elrepo-kernel
kernel-ml-tools-libs.x86_64                                     5.5.1-1.el7.elrepo                                  elrepo-kernel
kernel-ml-tools-libs-devel.x86_64                               5.5.1-1.el7.elrepo                                  elrepo-kernel
kernel-tools.x86_64                                             3.10.0-1062.9.1.el7                                 updates
kernel-tools-libs.x86_64                                        3.10.0-1062.9.1.el7                                 updates
kernel-tools-libs-devel.x86_64                                  3.10.0-1062.9.1.el7                                 updates
```
В репозитории есть две версии ядер **kernel-ml** и **kernel-lt**. 
Первая является наиболее свежей стабильной версией, вторая это стабильная версия с длительной поддержкой, но менее свежая, чем первая. 

В данном случае ядро 5й версии будет в  **kernel-ml**.

Поскольку мы ставим ядро из репозитория, то установка ядра похожа на установку любого другого пакета, но потребует явного включения репозитория при помощи ключа 
```--enablerepo```.

Ставим последнее ядро:

```
sudo yum --enablerepo elrepo-kernel install kernel-ml -y
```

### **grub update**
После успешной установки нам необходимо сказать системе, что при загрузке нужно использовать новое ядро. 
В случае обновления ядра на рабочих серверах необходимо перезагрузиться с новым ядром, выбрав его при загрузке. 
И только при успешно прошедших загрузке нового ядра и тестах сервера переходить к загрузке с новым ядром по-умолчанию. 
В тестовой среде можно обойти данный этап и сразу назначить новое ядро по-умолчанию. 

Обновляем конфигурацию загрузчика:
```
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
Выбираем загрузку с новым ядром по-умолчанию:

тут необходимо покапаться и уточнить из чего мы выбираем 
в файле /boot/grub2/grub.cfg есть строчки
```
menuentry 'CentOS Linux (3.10.0-957.12.2.el7.x86_64) 7 (Core)' --class centos --class gnu-linux --class gnu --class os --unrestricted $menuentry_id_option 'gnulinux-3.10.0-957.12.2.el7.x86_64-advanced-8ac075e3-1124-4bb6-bef7-a6811bf8b870'

и $default" = 'CentOS Linux (3.10.0-957.12.2.el7.x86_64) 7 (Core)' ]

```
```
sudo grub2-set-default 0
```

Перезагружаем виртуальную машину:
```
sudo reboot
```

После перезагрузки виртуальной машины (3-4 минуты, зависит от мощности хостовой машины) заходим в нее и выполняем:

```
[vagrant@kernel-update ~]$ uname -r
5.5.1-1.el7.elrepo.x86_64
```

---

# **Packer**
Теперь необходимо создать свой образ системы, с уже установленым ядром 5й версии. Для это воспользуемся ранее установленной утилитой `packer`. 
В директории `packer` есть все необходимые настройки и скрипты для создания необходимого образа системы.

делаем следующее 
```
cd packer
packer build centos.json
```

### **packer provision config**
Файл `centos.json` содержит описание того, как произвольный образ. Полное описание можно найти в документации к `packer`. Обратим внимание на основные секции или ключи.

Создаем переменные (`variables`) с версией и названием нашего проекта (artifact):
```
    "artifact_description": "CentOS 7.7 with kernel 5.x",
    "artifact_version": "7.7.1908",
```

В секции `builders` задаем исходный образ, для создания своего в виде ссылки и контрольной суммы. Параметры подключения к создаваемой виртуальной машине.

```
    "iso_url": "http://mirror.yandex.ru/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso",
    "iso_checksum": "9a2c47d97b9975452f7d582264e9fc16d108ed8252ac6816239a3b58cef5c53d",
    "iso_checksum_type": "sha256",
```
В секции `post-processors` указываем имя файла, куда будет сохранен образ, в случае успешной сборки

```
    "output": "centos-{{user `artifact_version`}}-kernel-5-x86_64-Minimal.box",
```

В секции `provisioners` указываем каким образом и какие действия необходимо произвести для настройки виртуальой машины. Именно в этой секции мы и обновим ядро системы, чтобы можно было получить образ с 5й версией ядра. Настройка системы выполняется несколькими скриптами, заданными в секции `scripts`.

```
    "scripts" : 
      [
        "scripts/stage-1-kernel-update.sh",
        "scripts/stage-2-clean.sh"
      ]
```
Скрипты будут выполнены в порядке указания. Первый скрипт включает себя набор команд, которые мы ранее выполняли вручную, чтобы обновить ядро. Второй скрипт занимается подготовкой системы к упаковке в образ. Она заключается в очистке директорий с логами, временными файлами, кешами. Это позволяет уменьшить результирующий образ. Более подробно можно ознакомиться с ними в директории `packer/scripts`

Секция `post-processors` описывает постобработку виртуальной машины при ее выгрузке. Мы указыаем имя файла, в который будет сохранен результат (artifact). Обратите внимание, что имя задается на основе ранее созданной пользовательской переменной `artifact_version` значение которой мы задали ранее:

```
    "output": "centos-{{user `artifact_version`}}-kernel-5-x86_64-Minimal.box",
```

### **packer build**
Для создания образа системы достаточно перейти в директорию `packer` и в ней выполнить команду:

```
packer build centos.json
```

Если все в порядке, то, согласно файла `config.json` будет скачан исходный iso-образ CentOS, установлен на виртуальную машину в автоматическом режиме, обновлено ядро и осуществлен экспорт в указанный нами файл. Если не вносилось изменений в предложенные файлы, то в текущей директории мы увидим файл `centos-7.7.1908-kernel-5-x86_64-Minimal.box`. Он и является результатом работы `packer`.

### **vagrant init (тестирование)**
Проведем тестирование созданного образа. Выполним его импорт в `vagrant`:

так как vagrant отказывается видеть box из другой папки то поступаем следующим образом, и выводим список всех box
```
>cd packer

\manual_kernel_update\packer>vagrant box add --name centos-7-5 centos-7.7.1908-kernel-5-x86_64-Minimal.box
==> box: Box file was not detected as metadata. Adding it directly...
==> box: Adding box 'centos-7-5' (v0) for provider:
    box: Unpacking necessary files from: file://C:/Users/emalinychev/Otus/OtusLinuxAdmin/manual_kernel_update/packer/centos-7.7.1908-kernel-5-x86_64-Minimal.box
    box:
==> box: Successfully added box 'centos-7-5' (v0) for 'virtualbox'!

\manual_kernel_update\packer>vagrant box list
centos-7-5 (virtualbox, 0)
centos/7   (virtualbox, 1905.1)
```
Он называться `centos-7-5`, данное имя было задалнно при помощи параметра `name` при импорте.

Теперь необходимо провести тестирование полученного образа. Для этого создадим новый Vagrantfile в директории `test` и в ней выполним:

```
manual_kernel_update\test>vagrant init centos-7-5
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.
```
Теперь запустим виртуальную машину, подключимся к ней и проверим, что у нас в ней новое ядро:

```
vagrant up
...
vagrant ssh    
```

и внутри виртуальной машины:

```
\manual_kernel_update\test>vagrant ssh
Last login: Mon Feb  3 19:31:32 2020 from 10.0.2.2
[vagrant@localhost ~]$ uname -r
5.5.1-1.el7.elrepo.x86_64
```

Все в порядке, машина запущена и загрузится с новым ядром. 

Удалим тестовый образ из локального хранилища:
```
vagrant box remove centos-7-5
```
---
# **Vagrant cloud**

Поделимся полученным образом с сообществом. Для этого зальем его в Vagrant Cloud. Можно залить через web-интерфейс, но так же `vagrant` позволяет это проделать через CLI.
Логинимся в `vagrant cloud`, указывая e-mail, пароль и описание выданого токена (можно оставить по-умолчанию)
```
vagrant cloud auth login
Vagrant Cloud username or email: <user_email>
Password (will be hidden): 
Token description (Defaults to "Vagrant login from DS-WS"):
You are now logged in.
```
Теперь публикуем полученный бокс:
```
vagrant cloud publish --release <username>/centos-7-5 1.0 virtualbox \
        centos-7.7.1908-kernel-5-x86_64-Minimal.box
```
Здесь:
 - `cloud publish` - загрузить образ в облако;
 - `release` - указывает на необходимость публикации образа после загрузки;
 - `<username>/centos-7-5` - `username`, указаный при публикации и имя образа;
 - `1.0` - версия образа;
 - `virtualbox` - провайдер;
 - `centos-7.7.1908-kernel-5-x86_64-Minimal.box` - имя файла загружаемого образа;

После успешной загрузки вы получите сообщение:

```
Complete! Published isysgen/centos-7-5
tag:             isysgen/centos-7-5-cli
username:        isysgen
name:            centos-7-5
private:         false
...
providers:       virtualbox
```

В результате создан и загружен в `vagrant cloud` образ виртуальной машины. Данный подход позволяет создать базовый образ виртульной машины с необходимыми обновлениями или набором предустановленного ПО. 
К примеру при создании MySQL-кластера можно создать образ с предустановленным MySQL, а при развертывании нужно будет добавить или изменить только настройки (то есть отличающуюся часть). 
Таким образом существенно экономя затрачиваемое время.

# **Заключение**

Результат выполнения ранее описанных действий по клонированию базового репозитория, созданию своего, создание кастомного образа с обновленным ядром и его публикация является необходимым для получения зачета по базовому домашнему заданию. 
Для проверки вам будет необходимо прислать ссылку на ваш репозиторий в чат с преподавателем в Личном кабинете. 
Репозиторий, соотвественно, должен быть публичным. На все возникшие вопросы можно получить ответ в переписке с преподавателем в чате с преподавателем или, что более рекомендуется, в слаке вашей группы.
