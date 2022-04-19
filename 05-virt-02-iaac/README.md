
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"

---

## Задача 1

### Вопрос 
- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

### Ответ 
Все преимущества вытекают из возможности автоматизации всех процессов построения нужной инфраструктуры, аналогично
разработке программного кода. Автоматизация это значит:
- скорость развертывания необходимой среды, а так же внесение изменений;
- стабильность конфигураций, т.е использование IaaC паттернов позволяет добиться сохранения однотипной конфигурации рабочей среды при масштабировании, переносе кода из тестовой среды в боевую и т.п.
- эффективность разработки, т.е. организация рабочего процесса разработчиков без необходимости самостоятельной настройки окружения, с возможностью быстрого "поднятия" необходимой инфраструктуры.

Основополагающий принцип - Идемпотентность. Это означает, что мы при многократном повторении всегда будем получать один и тот же предсказуемый результат.  

## Задача 2

### Вопрос 
- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

### Ответ
- Ansible использует SSH, что не требует установки дополнительного PKI-окружения.
- Push, на первый взгляд, кажется более надежным, т.к. подразумевает наличие одного управляющего сервера, который и управляет всеми изменениями.


## Задача 3

### Вопрос 
Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

### Ответ

На хостовой машине ОС Windows старой сборки без возможности использования WSL. Пробую вариант вложенной
виртуализации (Nested VT-x/AMD-v), для чего в VirtualBox для ВМ установил необходимы флаги.

**VirtualBox**
```bash
vagrant@vagrant:~$ virtualbox -h
Oracle VM VirtualBox VM Selector v6.1.32_Ubuntu
(C) 2005-2022 Oracle Corporation
All rights reserved.

No special options.

If you are looking for --startvm and related options, you need to use VirtualBoxVM.
```

**Vagrant**
```bash
vagrant@vagrant:~$ vagrant -v
Vagrant 2.2.6
```

**Ansible**
```bash
vagrant@vagrant:~$ ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
```

## Задача 4 (*)

### Вопрос 
Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```
### Ответ
Попытка использования вложенной виртуализации не увенчалась успехом - при поднятии виртуалки в виртуалке процесс
зависает на организации SSH. 

```bash
vagrant@vagrant:~/vgr$ vagrant up
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Importing base box 'bento/ubuntu-20.04'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'bento/ubuntu-20.04' version '202112.19.0' is up to date...
==> default: There was a problem while downloading the metadata for your box
==> default: to check for updates. This is not an error, since it is usually due
==> default: to temporary network problems. This is just a warning. The problem
==> default: encountered was:
==> default:
==> default: The requested URL returned error: 404 Not Found
==> default:
==> default: If you want to check for box updates, verify your network connection
==> default: is valid and try again.
==> default: Setting the name of the VM: vgr_default_1650356274760_80010
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Running 'pre-boot' VM customizations...
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
```

Достучаться до ВМ какими-либо способами не удалось, хотя она вроде бы запущена. Изучил все способы в интернете, не помогло.  

```bash
vagrant@vagrant:~/vgr$ vagrant status
Current machine states:

default                   running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

Вывод: нужно организовать нормальную рабочую станцию на Linux, чем и займусь в ближайшее время. 

