


### Homework 11 (ansible-4)

Branch build: [![Build Status](https://travis-ci.com/skushnerchuk/trytravis_infra.svg?branch=ansible-4)](https://travis-ci.com/otus-devops-2019-02/skushnerchuk_infra)
DB role build: [![Build Status](https://travis-ci.com/skushnerchuk/db.svg?branch=master)](https://travis-ci.com/skushnerchuk/db)

**Основное задание**

- Локальная разработка при помощи Vagrant - в Vagrantfile описаны конфигурации appserver, dbserver
- Добавлен плейбук base.yml для ansible bootstrap на хостах, где не установлен python
- Доработана роль db для использования в Vagrant, в которую добавлены таски config_mongo.yml, install_mongo.yml
- В Vagrantfile добавлены ansible провижинеры для appserver и dbserver
- Добавлены тесты роли db через molecula и testinfra


**Задания со \***

Роль **db** вынесена в [отдельный репозитарий](https://github.com/skushnerchuk/db). Для нее Подключен TravisCI для для автоматического прогона тестов в GCE.

<details>
<summary>Homework 10 (ansible-3)</summary>
### Homework 10 (ansible-3)

**Основное задание**

Созданы роли для для конфигурирования приложения и базы (инициализация структуры выполялась через команду **ansible-galaxy init**)

Playbooks переписаны на использование созданных ролей

Созданы отдельные окружения для управления через ansible: stage и prod. Inventory для каждого из окружения используется свой, и создается динамически.

В качестве окружения по умолчанию задано окружение storage

Добавлено использование групповых переменных.

Исследована работа с community ролями путем добавления в проект роли **jdauphant.nginx**

В конфигурацию terraform добавлено правило, открывающее 80 порт для nginx

С помощью ansible-vault организовано добавление новых пользователей в систему через новый playbook.

**Задание со \*, слайд 55**

Для каждого окружения задано свой динамический Inventory

**Задание с \*\*, слайд 56, 57**

Добавлены дополнительные проверки для Travis-CI
Отладка тестов проводилось с помощью trytravis и репозитария trytravis_infra
</details>

<details>
<summary>Homework 9 (ansible-2)</summary>
### Homework 9 (ansible-2)

**Основное задание**

Отключен provisioner в конфигурации terraforn (через переменную)

Созданы playbook, с помощью которых выполняется установка и настройка приложения и базы данных.

Исследовано поведение ansible handlers

Основной playbook разбит на несколько (app.yml, db.yml, deploy.yml, site.yml)

**Задание со \***
В качестве динамического inventory вполне можно использовать плагин **gcp_compute**
Пример конфиграции может выглядеть так:

```
sample_di.gcp.yml
---
plugin: gcp_compute
projects:
  - my-project
zones:
  - "europe-west1-b"
filters: []
auth_kind: serviceaccount
service_account_file: "project.json"
```

Проверить работоспособность можно командой:
```
ansible -i sample_di.gcp.yml all -m ping
```
Однако я решил оставить свое решение - скрипт на питоне, который формирует inventory на лету.

**Задание по изменению provision в исходных образах**

Созданы playbooks, предназначенные на замену скриптам, используемым при формировании исходных образов.

На основании этих playbooks собраны образы, развернуто окружение и проверена работоспособность созданных ранее playbooks для развертывания приложения и базы.
</details>

<details>
<summary>Homework 8 (ansible-1)</summary>
### Homework 8 (ansible-1)

**Задание 1.** Установка ansible

Выполнена установка ansible и созданы необходимые папки и файлы для начала работы

**Задание 2.** Основы Ansible

Создан файл inventory с описанием хостов из существующей инфраструктуры, проверено:

его доступность с опомщью команд
```
ansible appserver -i ./inventory -m ping
ansible dbserver -i ./inventory -m ping
```
Создан файл конфигурации **ansible.cfg**

Проверено, что ansible подхватывает параметры конфигурации из созданного файла командой
```
ansible dbserver -m command -a uptime
```

**Задание 3.** Работа с группами хостов, использование YAML для описания inventory

Файл inventory переписан для формирования 2-х групп - **app** и **db**, проверено управление всеми хостами группы командой
```
ansible app -m ping
```
Создано описание inventory в формате YAML (inventory.yml):
```
ansible all -m ping -i inventory.yml
```
Исследовано выполнение команд оболочки с помощью модулей **command** и **shell**

**Задание 4.** Основы создания playbooks

Создан простой playbook **clone.yml**, выполняющий клонирование репозитария с приложением на хост приложения.
При выполнении этого playbook никаких изменений на хосте не происходит, так как папка с приложением уже есть.
После удаления папки командой
```
ansible app -m command -a 'rm -rf ~/reddit'
```
и повторного проигрывания playbook папка будет склонирована из репозитария:
```
PLAY [Clone]
TASK [Gathering Facts] ok: [35.195.199.144]
TASK [Clone repository] changed: [35.195.199.144]

35.195.199.144             : ok=2    changed=1    unreachable=0    failed=0
```

**Задание со \*, слайд 33** Исследование динамических inventory

Создан файл статического inventory.json, проверена его работоспособность командой
```
{

	"app": {
		"hosts": {
			"appserver": {
				"ansible_host": "35.195.199.144"
			}
		}
	},
	"db": {
		"hosts": {
			"dbserver": {
				"ansible_host": "35.241.212.147"
			}
		}
	}
}
--------------------------------------------------
ansible all -m ping

  appserver | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }
  dbserver | SUCCESS => {
      "changed": false,
      "ping": "pong"
  }
```
после его добавления в ansible.cfg в качестве inventory по умолчанию

Создан скрипт **dynamic_inventory.py**, генерирующий inventory на лету на основании указанных данных проекта инфраструктуры
</details>

<details>
<summary>Homework 7 (terraform-2)</summary>
### Homework 7 (terraform-2)
**Задание 1.** Импорт существующих сущностей в конфигурацию Terraform

Сделан импорт правила фаервола

**Задание 2.** Исследование взаимосвязей ресурсов инфраструктуры

Задан IP экземпляра ВМ с приложением с помощью ресурса **google_compute_address**
Созданный ресурс был использован в описании экземпляра ВМ в секции **network_interface**

Выполнено разделение инфраструктуры на 2 модуля, каждый из которых создает свой экземпляр ВМ: приложения и базы данных.

Правило фаервола для ssh-доступа вынесено в отдельный модуль

В целях исследований возможности переиспользования модулей были созданы 2 окружения (stage, prod)

**Задание со \*, слайд 64**

Хранение состояния инфраструктуры перенесено в облако (remote backends)

**Задание с 2 \*, слайд 65**

Добавлены файлы и настройки для деплоя приложения в модуль app.

</details>

<details>
<summary>Homework 6 (terraform-1)</summary>
### Homework 6 (terraform-1)

**Задание 1.** Установка утилиты terraform. Подготовка и отладка конфигурации инфтрастуртуры.

Сформированы файлы, необходимые для формирования инфтраструктуры, добавлены описания ресурсов, переменных и их значений в соответствии с рекомендациями.

**Задание со \*, слайд 51.**

Для добавления ключа одного пользователя я использовал ресурс **google_compute_project_metadata_item**
```
resource "google_compute_project_metadata_item" "ssh_1" {
  key   = "ssh-keys"
  value = "appuser1:${file(var.public_key_path)}"
}
```

Для добавления нескольких ключей использовался ресурс **google_compute_project_metadata**
```
resource "google_compute_project_metadata" "ssh_keys" {
  metadata {
    ssh-keys = <<EOF
    appuser1:${trimspace(file(var.public_key_path))}
    appuser2:${trimspace(file(var.public_key_path))}
    appuser3:${trimspace(file(var.public_key_path))}
    appuser4:${trimspace(file(var.public_key_path))}EOF
  }
}
```

**Задание со \*, слайд 52.**
Если мы добавим ключ пользователя через web-интерфейс GCP, а потом выполним команду
```
terraform apply
```
то все доавленное нами ранее будет заменено на то, что указано в описании конфигурации.

**Задание со \*\*, слайд 53.**
Описание балансировщика приведено в файле lb.tf
Проверена работа балансировщика путем:
- остановки сервиса puma
- остановки одного и всех экземпляров ВМ

**Задание со \*\*, слайд 54.**
Был добавлен еще один экземпляр ВМ с приложением путем копирпования конфигурации предыдущего экземпляра. Такой подход неудовлетворителен, так как приводит к возрастанию вероятности ошибки при изменении конфигураций, а также к увеличеню трудозатрат на ее поддержание.

**Задание со \*\*, слайд 55.**
Конфигурация была изменена на использование счетчика **count**. Добавлена переменная, с помощью которой можно регулировать количество экземпляров приложения.
</details>

<details>
<summary>Homework 5 (packer-base)</summary>
### Homework 5 (packer-base)

**Задание 1.** Установка утилиты packer. Подготовка шаблона для packer.

Сформирован шаблон образа **ubuntu16.json**, кооторый юудет содержать в себе предустановленные monпodb и ruby.
Проверена работоспособность образа путем развертывания из него экземпляра ВМ, установки и проверки работы тестового приложения.

**Задание 2.** Формирование образа, содержащего в себе предустановленное тестовое приложение.

Сформирован шаблон **immutable.json**, описывающий образ системы с предустановленным тестовым приложением.
Созданы скрипты для развертывания приложения в процессе сборки образа, а также установки приложения как демона с использованием systemd.

**Задание 3.** Создание экземпляра ВМ из образа с предустановленным тестовым приложением.

Команда формирования экземпляра ВМ (см. также скрипт create-reddit-vm.sh):

```
gcloud compute instances create reddit-app\
  --image-family reddit-full \
  --machine-type=f1-micro \
  --tags puma-server \
  --zone europe-west1-b \
  --restart-on-failure
```
</details>

<details>
<summary>Homework 4 (cloud-testapp)</summary>
### Homework 4 (cloud-testapp)
testapp_IP = 35.195.151.40
testapp_port = 9292

**Задание 1.** Установка и настройка утилиты gcloud, создание виртуальной машины
для развертывания тестового приложения, и его развертывание.

Для создания вирутальной машины использовалась команда:

```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure
```

Для развертывания тестового приложения были сформированы скрипты:
```
install_ruby.sh
install_mongodb.sh
deploy.sh
```

**Задание 2.** Создание инстанса вирутальной машины и автоматическое развертывание тестового приложения

Для выполнения задания был создан скрипт, выполняемый автоматически при создании виртуальной машины

```
startup.sh
```

Создание виртуальной машины и развертывание приложения выполняется с помощью команды:

```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=startup.sh
```

**Задание 3.** Создание правила фаервола с помощью утилиты gcloud:
```
gcloud compute firewall-rules create default-puma-server --allow tcp:9292 --target-tags puma-server
```
</details>


<details>
<summary>Homework 3 (cloud-bastion)</summary>
### Homework 3 (cloud-bastion)

bastion_IP=35.189.248.149
someinternalhost_IP=10.142.0.2

**Задание 1.** Исследовать способ подключения к someinternalhost в одну команду из вашего рабочего устройства

Для подключения одной командой будем использовать опцию ProxyJump команды ssh:
```
ssh -i ~/.ssh/gc_key -J appuser@35.189.248.149 appuser@10.142.0.2
```

**Задание 2.** Предложить вариант решения для подключения из консоли при помощи команды вида ssh someinternalhost
из локальной консоли рабочего устройства, чтобы подключение выполнялось по алиасу someinternalhost

Для реализации такой схемы подключения используем настройки SSH в файле ~/.ssh/config
```
# Включаем SSH Agent Forwarding для всех хостов
Host *
   ForwardAgent yes

# Описываем схемы нужных хостов
Host bastion
   HostName 35.189.248.149
   User appuser
   IdentityFile ~/.ssh/gc_key

Host someinternalhost
   HostName 10.142.0.2
   ProxyJump bastion
   User appuser
   IdentityFile ~/.ssh/gc_key
```

**Задание 3.** С помощью сервисов sslip.io / xip.io и Let’s Encrypt реализуйте использование валидного сертификата
для панели управления VPN-сервера

Использовался сервис sslip.io, итоговый адрес: https://35.189.248.149.sslip.io/

Скриншот, подтверждающий успешное выполнение задания:

![alt text](./VPN/certificate.png)
</details>
