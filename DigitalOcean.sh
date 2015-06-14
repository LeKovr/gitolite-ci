#!/bin/bash

# ----------------------------------------------------------------
# Файл DigitalOcean.conf - начало

# Значения из кабинета DigitalOcean
client_id=******
api_key=*****

# ID ключа ssh
#GET "https://api.digitalocean.com/ssh_keys/?client_id=$client_id&api_key=$api_key"
ssh_key=00000

# Имя хоста капли
hname="cloud1.tld"

watcher="admin@tld"

# Файл DigitalOcean.conf - конец
# ----------------------------------------------------------------


# Заполним указанные выше переменные реальными данными
. DigitalOcean.conf

#GET "https://api.digitalocean.com/images/?client_id=$client_id&api_key=$api_key&filter=global"
# {"id":308287,"name":"Debian 7.0 x64","slug":"debian-7-0-x64","distribution":"Debian","public":true
# , "regions":[1,2,3,4,5,6],"region_slugs":["nyc1","ams1","sfo1","nyc2","ams2","sgp1"]}
# {"id":1505447,"name":"Ubuntu 12.04.3 x64","slug":"ubuntu-12-04-x64","distribution":"Ubuntu","public":true
# , "regions":[1,2,3,4,5,6],"region_slugs":["nyc1","ams1","sfo1","nyc2","ams2","sgp1"]}
# {"id":11851919,"name":"Docker 1.6.2 on 14.04","slug":"docker","distribution":"Ubuntu","public":true,
# "regions":[1,2,3,4,5,6,7,8,9,10],"region_slugs":["nyc1","ams1","sfo1","nyc2","ams2","sgp1","lon1","nyc3","ams3","fra1"]},
image_id=11851919

#GET "https://api.digitalocean.com/regions/?client_id=$client_id&api_key=$api_key"
# {"id":5,"name":"Amsterdam 2","slug":"ams2"}
region_id=5

#GET "https://api.digitalocean.com/sizes/?client_id=$client_id&api_key=$api_key"
# {"id":66,"name":"512MB","slug":"512mb","memory":512,"cpu":1,"disk":20,"cost_per_hour":0.00744,"cost_per_month":"5.0"}
size_id=66


GET "https://api.digitalocean.com/droplets/?client_id=$client_id&api_key=$api_key" | grep -q "\"name\":\"$hname\"" || {
  echo "Капля $hname не обнаружена, пробуем создать..."
  read -p "[Hit Enter to continue]" X

URI0=$(cat <<EOF
client_id=$client_id&api_key=$api_key&ssh_key_ids=$ssh_key&
name=$hname&image_id=$image_id&size_id=$size_id&region_id=$region_id
EOF
)
URI=$(echo $URI0 | tr -d '\n ')


echo "Отправляем команду на создание капли $hname..."

RET=$(GET "https://api.digitalocean.com/droplets/new?$URI")
#RET='{"status":"OK","droplet":{"id":1403023,"name":"$hname","image_id":308287,"size_id":66,"event_id":20556952}}'

[[ "$RET" != "${RET#\{\"status\":\"OK\"}" ]] || {
  echo "Error: $RET"
  exit 1
}
echo "Success: $RET"

cat <<EOF
Производится создание и загрузка капли...

Если на текущем аккаунте DigitalOcean ранее уже была создана и удалена капля, то новая получит тот же ip-адрес.
Если этот ip-адрес уже был зарегистрирован в DNS за именем $hname,
то работа скрипта продолжится автоматически по факту загрузки (успешного пинга) капли.

Иначе - посмотрите в кабинете ip капли, зарегистрируйте его в DNS и повторите запуск скрипта после обновления зоны

EOF

}

echo -n "Пингую каплю $hname..."
while true; do ping -c1 $hname > /dev/null && break; done

echo "OK"
  read -p "[Hit Enter to continue]" X

# У новой капли новый ECDSA key
# надо удалить старый, если есть
ssh-keygen -f ~/.ssh/known_hosts -R $hname

# RSA ключ текущего пользователя помещен в каплю при ее создании, поэтому можем логиниться

ssh -t root@$hname 'bash -s' << EOF

# stop on error
set -e

# https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04

# Enable swap
SWAP=/swapfile
[ -f \$SWAP ] || {
  fallocate -l 4G \$SWAP
  chmod 600 \$SWAP
  mkswap \$SWAP
  swapon \$SWAP
  echo "\$SWAP   none    swap    sw    0   0" >> /etc/fstab
}

# Other tuning
grep vm.swappiness /etc/sysctl.conf || {
  echo "vm.swappiness=10" >> /etc/sysctl.conf
  sysctl vm.swappiness=10
}

grep vfs_cache_pressure /etc/sysctl.conf || {
  echo "vfs_cache_pressure=50" >> /etc/sysctl.conf
  sysctl vm.vfs_cache_pressure=50
}

# --------------------------------------------------------------------
# Настроить локаль пользователя если необходимо
locale-gen $LC_NAME

# update debs
apt-get update
apt-get upgrade -y
# apt-get install -y linux-generic linux-headers-generic linux-image-generic


# создадим пользователя (op)
NEWUSER=op
HOMEROOT=/home/app
HOMEDIR=\$HOMEROOT/\$NEWUSER
[ -d \$HOMEROOT ] || mkdir \$HOMEROOT

# Check if user exists already
grep -qe "^\$NEWUSER:" /etc/passwd || useradd -d \$HOMEDIR -m -r -s /bin/bash -Gwww-data -gusers -gdocker \$NEWUSER
[ -d \$HOMEDIR/.ssh ] || sudo -u \$NEWUSER mkdir -m 700 \$HOMEDIR/.ssh

KEYFILE=\$HOMEDIR/.ssh/authorized_keys
if [ ! -f \$KEYFILE ] ; then
  cp /root/.ssh/authorized_keys \$KEYFILE
  chown \$NEWUSER \$KEYFILE
  chmod 600 \$KEYFILE
fi

# allow sudo without pass
[ -f /etc/sudoers.d/\$NEWUSER ] || {
  echo "\$NEWUSER ALL=NOPASSWD:ALL" > /etc/sudoers.d/\$NEWUSER
  chmod 440 /etc/sudoers.d/\$NEWUSER
}

# UFW on
ufw allow OpenSSH
echo 'y' | ufw enable

# Deny root login via ssh
sed -i "/^PermitRootLogin.*/c PermitRootLogin no" /etc/ssh/sshd_config

# Deny password login
sed -i "/#PasswordAuthentication *yes/c PasswordAuthentication no" /etc/ssh/sshd_config

service ssh reload

# Install fidm

FIDM_VER=v0.1 \
  && curl -o /usr/local/bin/fidm \
          -SL https://raw.githubusercontent.com/LeKovr/fidm/${FIDM_VER}/fidm.sh \
  && chmod +x /usr/local/bin/fidm

EOF

  read -p "[Hit Enter to continue]" X
# Теперь доступ к ssh есть только у пользователя op

ssh -t op@$hname 'bash -s' << EOF
# установка gitolite и gitolite-ci
curl -s https://raw.githubusercontent.com/LeKovr/gitolite-ci/master/install.sh | bash

EOF

  read -p "[Hit Enter to continue]" X

# Управление gitolite производим с локального компа

[ -d $hname ] || mkdir $hname
pushd $hname

echo "Загружается скрипт добавления проектов в репозиторий"
wget https://raw.githubusercontent.com/LeKovr/gitolite-ci/master/project-add.sh

# Файл gitolite-ci.conf будет создан при первом запуске project-add.sh
# но тогда его надо будет редактировать руками

[ -f gitolite-ci.conf ] || cat > gitolite-ci.conf <<EOF
# gitolite-ci host config

# ssh hostname
CFGHOST=$hname

# admin username
ADMIN="op"

# gitolite notification email(s)
WATCHERS="$watcher"

EOF

# создать в gitolite сервера $hname проект mail
bash project-add.sh mail

cat <<EOF

На сервере $hname зарегистирован проект mail

Варианты использования:

1. Разработка
  git clone git@$hname:mail
  # ..редактирование
  git add .
  git commit -am "comment"
  git push origin master

2. Выгрузка

   # Подключаем $hname к некоторому проекту
   git remote add cloud1 git@$hname:mail

   # Выгрузка текущего состояния каталога в $hname:mail
   git push cloud1 master

После выполнения git push содержимое проекта будет развернуто в каталоге
/home/app/srv/mail/master
и, если там будет файл setup.sh, он будет выполнен.

Для того, чтобы при push отправлялось почтовое уведомление,
необходимо настроить отправку почты.

Согласно текущим настройкам капли, для отправки почты используется ssmtp,
конфигурация которого берется из файла /home/app/srv/mail/ssmtp.conf.

Для отправки почты создадим почтовый домен @$hname и настроим для него DKIM и SPF
EOF

  read -p "[Hit Enter to continue]" X

git clone git@$hname:mail
pushd mail
# настройка и старт контейнера docker с образом lekovr/mail
wget https://raw.githubusercontent.com/LeKovr/gitolite-ci/master/remote/setup.sh
# разрешение на старт
echo 1 > enabled
git add .
git commit -am "added setup"
git push origin master

# При выполнении push на сервере будет запущен setup.sh, загружен и стартован контейнер

# Какие изменения должны быть внесены в DNS:
# (команда подходит для случая, когда запущен только один контейнер docker)

  read -p "[Hit Enter to continue]" X

ssh op@$hname 'docker logs $(sudo docker ps -q)'

  read -p "[Hit Enter to continue]" X

# Если у нас нет ключа для подписи DKIM - используем сформированный при первом старте контейнера
# ssh op@$hname sudo cat /home/app/srv/mail/private.key > private.key
# git add private.key
# git ci -am "added private.key"
# git push

# Если ключ сформирован ранее, добавим его в проект
# git add private.key
# git ci -am "added private.key"
# git push
# и зарегистрируем его, залогинившись в контейнер mail
#  ssh -p 32 op@$hname sudo cp -f /home/app/srv/mail/master/private.key /home/app/srv/mail/private.key
#  ssh -p 32 op@$hname sudo chown opendkim /home/app/srv/mail/private.key

# Проверим, что почта работает
#  echo "# t1" >> setup.sh
#  git ci -am test1
#  git push

##########################################################################################


# TODO: управление DNS 
#GET "https://api.digitalocean.com/domains?client_id=$client_id&api_key=$api_key"
# {"status":"OK","domains":[{"id":162593,"name":"el-f.pro",...

#GET https://api.digitalocean.com/domains/[domain_id]/records?client_id=[client_id]&api_key=[api_key]
