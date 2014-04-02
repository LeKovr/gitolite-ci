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
apt-get -y install git-core moreutils ssmtp

# -----------------
# Setup gitolite-ci
# -----------------

# host user - files owner
GITUSER=git
HOMEDIR=/home/app/$GITUSER

# Create user $GITUSER
grep -qe "^$GITUSER:" /etc/passwd || useradd -d $HOMEDIR -m -r -s /bin/bash -Gwww-data -gusers $GITUSER
usermod -L $GITUSER

# Setup current user's name & key as gitolite admin
$HOMEDIR/$USER.pub || cat ~/.ssh/authorized_keys | head -1 > $HOMEDIR/$USER.pub

# Enable sudo for $GITUSER
[ -f /etc/sudoers.d/$GITUSER ] || {
  cat > /etc/sudoers.d/$ITUSER <<-EOF
	$NEWUSER ALL=NOPASSWD:/usr/bin/supervisorctl
	$NEWUSER ALL=NOPASSWD:/usr/sbin/nginx
	$NEWUSER ALL=NOPASSWD:/usr/bin/docker
	$NEWUSER ALL=($NEWUSER) NOPASSWD:ALL
	EOF
  chmod 440 /etc/sudoers.d/$GITUSER
}

# Setup app deploy root

# Deploy root
APPROOT=/home/app/srv

[ -d $APPROOT ] || mkdir -p $APPROOT
chown $GITUSER:www-data $APPROOT
chmod ug+w $APPROOT

# Setup rest as $GITUSER

su - $GITUSER
cd

[ -d gitolite-ci ] || git clone https://github.com/LeKovr/gitolite-ci.git
echo $USER | . gitolite-ci/remote/init.sh
