gitolite-ci
===========

Scripts to make Continuous Integration with gitolite

Prepare
-------

1. Create cloud server
2. Generate RSA keys
3. Copy keys to server
4. Update server with [dish](https://github.com/LeKovr/dish) [see](https://github.com/LeKovr/dish/blob/master/README.ru.md#%D0%A1%D0%B5%D1%80%D0%B2%D0%B5%D1%80-%D0%B2-%D0%BE%D0%B1%D0%BB%D0%B0%D0%BA%D0%B5)

Usage
-----

### Install 

Login as root via key and run

    curl https://raw.githubusercontent.com/LeKovr/gitolite-ci/master/install.sh | bash


What will be done:

1. 

### Add project

    project-add.sh test01
