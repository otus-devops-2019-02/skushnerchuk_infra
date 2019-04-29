#!/usr/bin/env python3

import os
import json
from json.decoder import JSONDecodeError
from argparse import ArgumentParser
import warnings
import logging

import googleapiclient.discovery
from googleapiclient.errors import HttpError


# Переменные, необходимые для получения списка экземпляров ВМ
ZONE = 'europe-west1-b'
PID = 'infra-12345'

# Шаблон, используемый для построения inventory
TEMPLATE = {
    "_meta": {
      "hostvars": {}
    },
    "app": {
      "hosts": [],
      "vars": {}
    },
    "db": {
      "hosts": [],
      "vars": {}
    }
}

EMPTY_INVENTORY = {
    '_meta': {
      'hostvars': {}
    }
}

# Гасим ненужное предупреждение об использовании данных авторизации
warnings.filterwarnings("ignore", "Your application has authenticated using end user credentials")
# Логгирование
log_filename = os.path.realpath(__file__) + '.log'
logging.basicConfig(filename=log_filename, level=logging.DEBUG)


class AnsibleInventory:
    """
    Примитивный класс формирования динамического inventory
    """

    def __init__(self):
        self.inventory = {}
        self.args = None
        self.read_arguments()

    def read_arguments(self):
        parser = ArgumentParser()
        parser.add_argument('--list', action='store_true')
        self.args = parser.parse_args()
        logging.debug('Arguments:')
        logging.debug(self.args)
        logging.debug('========================')

    @staticmethod
    def empty_inventory():
        return EMPTY_INVENTORY

    @staticmethod
    def instances_from_gcp():
        """
        Получение сведений о экземплярах ВМ
        :return: Список экземпляров ВМ, или пустой список, если произошла ошибка или ВМ jncencnde.n
        """
        try:
            compute = googleapiclient.discovery.build('compute', 'v1')
            result = compute.instances().list(project=PID, zone=ZONE).execute()
            return result['items'] if 'items' in result else []
        except HttpError:
            return []

    def create(self):
        """
        Создание динамического inventory
        :return: словарь, описывающий inventory. При ошибке получения данных из GCP возвращается
                 пустой inventory
        """
        # Если указан аргумент --list, пытаемся строить inventory из проекта GCP
        if self.args.list:
            instances = self.instances_from_gcp()
            if not instances:
                return self.empty_inventory()
            answer = TEMPLATE
            # В inventory попадают только экземпляры ВМ с внешним IP
            for ins in instances:
                network = ins.get('networkInterfaces', None)
                if not network:
                    continue
                access_config = network[0].get('accessConfigs', None)
                if not access_config:
                    continue
                nat_ip = access_config[0].get('natIP', None)
                if not nat_ip:
                    continue
                if 'app' in ins['name']:
                    answer['app']['hosts'].append(ins['name'])
                    answer['app']['vars']['ansible_host']= nat_ip
                elif 'db' in ins['name']:
                    answer['db']['hosts'].append(ins['name'])
                    answer['db']['vars']['ansible_host']= nat_ip
            return answer
        # При обычном запуске выводим inventory.json, если он есть, или пустой inventory
        return self.load_inventory_file()

    def load_inventory_file(self):
        """
        Загрузка inventory из локальногь файла
        :return: содержимое файла или пустой inventory при его отсутствии
        """
        try:
            with open('inventory.json') as f:
                body = json.load(f)
            return body
        except (IOError, JSONDecodeError):
            return self.empty_inventory()


if __name__ == '__main__':
    a = AnsibleInventory()
    inventory = a.create()
    logging.debug('Inventory:')
    logging.debug(inventory)
    logging.debug('===================')
    print(json.dumps(inventory, ensure_ascii=False))
