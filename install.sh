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
  sudo cat > /etc/sudoers.d/$GITUSER <<-EOF
	$NEWUSER ALL=NOPASSWD:/usr/bin/supervisorctl
	$NEWUSER ALL=NOPASSWD:/usr/sbin/nginx
	$NEWUSER ALL=NOPASSWD:/usr/bin/docker
	$NEWUSER ALL=($NEWUSER) NOPASSWD:ALL
	EOF
  sudo chmod 440 /etc/sudoers.d/$GITUSER
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

sudo su - $GITUSER
cd

[ -d gitolite-ci ] || git clone https://github.com/LeKovr/gitolite-ci.git
echo $APPROOT/$USER.pub | . gitolite-ci/remote/init.sh

exit
rm $APPROOT/$USER.pub
