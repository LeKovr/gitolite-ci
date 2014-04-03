#
# Use:
#   ssh -t root@example.com 'bash -s' < install.sh
# or
#   curl https://raw.github.com/lekovr/gitolite-ci/install.sh | bash


# Install docker if none
dpkg -s lxc-docker > /dev/null 2>&1 || {
  echo "It seems that lxc-docker is not installed. Trying to fix.."
  curl -s https://get.docker.io/ubuntu/ | sudo sh
  # allow conect between containers
  # sed -i "/^DEFAULT_FORWARD_POLICY=\"DROP\"/c DEFAULT_FORWARD_POLICY=\"ACCEPT\"" /etc/default/ufw

}

# Install gitolite deps
sudo apt-get -y install git-core moreutils ssmtp

# -----------------
# Setup gitolite-ci
# -----------------

# host user - files owner
GITUSER=git
HOMEDIR=/home/$GITUSER

# Create user $GITUSER
grep -qe "^$GITUSER:" /etc/passwd || sudo useradd -d $HOMEDIR -m -r -s /bin/bash -Gwww-data -gusers $GITUSER
sudo usermod -L $GITUSER

# Enable sudo for $GITUSER
[ -f /etc/sudoers.d/$GITUSER ] || {
  sudo bash -c "cat >/etc/sudoers.d/$GITUSER <<-EOF
	$GITUSER ALL=NOPASSWD:/usr/bin/supervisorctl
	$GITUSER ALL=NOPASSWD:/usr/sbin/nginx
	$GITUSER ALL=NOPASSWD:/usr/bin/docker
	$GITUSER ALL=($GITUSER) NOPASSWD:ALL
	EOF
  "
  sudo chmod 440 /etc/sudoers.d/$GITUSER
}

# Setup ssmtp
[ -L /etc/ssmtp/ssmtp.conf ] || {
  # делаем символьную ссылку на файл, поторый будет сформирован пользователем git при старте контейнера mail
  sudo mv /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.pre
  sudo ln -s /home/app/srv/mail/ssmtp.conf /etc/ssmtp/ssmtp.conf 
}

# Setup app deploy root

# Deploy root
APPROOT=/home/app/srv

[ -d $APPROOT ] || sudo mkdir -p $APPROOT
sudo chown $GITUSER:www-data $APPROOT
sudo chmod ug+w $APPROOT

# Setup current user's name & key as gitolite admin
[ -f $APPROOT/$USER.pub ] || cat ~/.ssh/authorized_keys | head -1 > $APPROOT/$USER.pub

# Setup rest as $GITUSER
pushd $HOMEDIR

[ -d gitolite-ci ] || sudo sudo -u $GITUSER git clone https://github.com/LeKovr/gitolite-ci.git
echo $APPROOT/$USER.pub | sudo sudo -u $GITUSER bash gitolite-ci/remote/init.sh

rm $APPROOT/$USER.pub
