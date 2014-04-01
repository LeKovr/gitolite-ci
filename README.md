gitolite-ci
===========

Scripts to make Continuous Integration with gitolite

Prepare
-------

### Create cloud server

Hostname will be used as mail domain.

### Generate keys

### Copy keys to server

Usage
-----

### Install 

Login as root via key and run

    curl https://raw.github.com/lekovr/gitolite-ci/system-init.sh | bash -s YOUR@MAIL ADMIN GIT

Where

* *YOUR@MAIL* - The person who gets all mail from server
* *ADMIN* - Username to login as root
* *GIT* - Username to interact with gitolite-ci

### Add project

    project-add.sh test01
