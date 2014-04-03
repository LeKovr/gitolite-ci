gitolite-ci
===========

Шелл-скрипты для реализации на базе gitolite понятия "Непрерывная интеграция" 

Подготовка
----------

1. [Создать облачный сервер](https://www.digitalocean.com/?refcode=eb72bdfe3ce4)
2. [Создать ключи и поместить их на сервер](https://www.digitalocean.com/community/articles/how-to-set-up-ssh-keys--2)
3. Обновить сервер по рецептам [dish](https://github.com/LeKovr/dish) согласно [инструкции](https://github.com/LeKovr/dish/blob/master/README.ru.md#%D0%A1%D0%B5%D1%80%D0%B2%D0%B5%D1%80-%D0%B2-%D0%BE%D0%B1%D0%BB%D0%B0%D0%BA%D0%B5)

Установка на сервере
--------------------

4. Авторизоваться пользователем
5. Выполнить

    curl -s https://raw.githubusercontent.com/LeKovr/gitolite-ci/master/install.sh | sudo bash

Использование
-------------

### Конфигурация сервера

Допустим, в процессе установки был создан и настроен облачный сервер cloud1.example.com

```
$ mkdir cloud1
$ cd cloud1
$ wget https://raw.githubusercontent.com/LeKovr/gitolite-ci/master/project-add.sh
$ bash project-add.sh

# Сформирован шаблон файла gitolite-ci.conf
# Редактируем gitolite-ci.conf

$ bash project-add.sh mail
...
Project mail setup complete.
Clone it via:
  git clone git@cloud1.el-f.pro:mail
```


### Конфигурация локальной копии

### Add project

    project-add.sh test01
