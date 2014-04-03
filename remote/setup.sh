

# имя домена совпадает с именем мастер-хоста
MAILDOMAIN=$HOSTNAME

APPROOT=/home/app

# Check dkim key

[ -f private.key ] && {
  # этот файл есть только на ветках, соответствующих серверам
  # используем его как флаг необходимости стартовать почтовый сервер

  # opendkim ищет его в /home/app/mail/
  [ -e ../private.key ] || ln -s $(basename $PWD)/private.key ../private.key

  # Для создания файла private.key неоходимо
  # стартовать контейнер на сервере, там будет создан файл
  # выполнить 
  #  scp op@HOST:/home/app/srv/mail/private.key .
  #  git add private.key
}

[ -f ../ssmtp.conf ] || cat > ../ssmtp.conf <<-EOF
	mailhub=127.0.0.10:35
	rewriteDomain=$MAILDOMAIN
	hostname=$MAILDOMAIN
	# root=TODO: где-то на сервере хранить email админа
EOF

# TODO: эта операция выполняется вручную, надо решить по правам доступа
#[ -L /etc/ssmtp/ssmtp.conf ] || {
#  mv /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.pre
#  ln -s /home/app/srv/mail/ssmtp.conf /etc/ssmtp/ssmtp.conf 
#}

[ -f enabled ] && [[ "$(cat enabled)" == "1" ]] && {
  # стартуем docker

  # dish run mail:06 -rm -P -e MAILDOMAIN=cloud.el-f.pro
  if sudo docker ps | grep mail ; then 
    echo "Docker already run"
  else
    echo "Starting Docker..."
    sudo docker run -d -h mail -v $APPROOT:/home/app \
      -e DISHMODE=bg -p 127.0.0.10:35:25 -p 32:22 \
      -e MAILDOMAIN=$MAILDOMAIN \
      lekovr/mail
    sudo docker ps
  fi
}
