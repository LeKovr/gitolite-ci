gitolite-ci
===========

Шелл-скрипты для реализации на базе gitolite понятия "Непрерывная интеграция" 

Подготовка
----------

1. [Создать облачный сервер]()
2. [Создать ключи и поместить их на сервер]
3. Обновить сервер по рецептам [dish](https://github.com/LeKovr/dish) согласно [инструкции](https://github.com/LeKovr/dish/blob/master/README.ru.md#%D0%A1%D0%B5%D1%80%D0%B2%D0%B5%D1%80-%D0%B2-%D0%BE%D0%B1%D0%BB%D0%B0%D0%BA%D0%B5)

Установка на сервере
--------------------

4. Авторизоваться пользователем
5. Выполнить
    curl -s https://raw.githubusercontent.com/LeKovr/gitolite-ci/master/install.sh | bash

Использование
-------------

### Конфигурация сервера


### Конфигурация локальной копии

### Add project

    project-add.sh test01
