#
# Use:
# ssh -t root@example.com 'bash -s' < system-init.sh

# host user - files owner
USER=git

# git admin
ADMIN=op

# Deploy root
ROOT=/home/app/srv

# Cloud host default key
KEY0=/root/.ssh/authorized_keys

# Dish host  default key
KEY1=/home/app/op/.ssh/authorized_keys

# Disallow shell questions
export DEBIAN_FRONTEND=noninteractive

apt-get -y install git-core moreutils ssmtp

grep -qe "^$USER:" /etc/passwd || {
  useradd -b /home m $USER
  usermod -L $USER

  cat > /etc/sudoers.d/$USER <<-EOF
	$USER ALL=NOPASSWD:/usr/bin/supervisorctl
	$USER ALL=NOPASSWD:/usr/sbin/nginx
	$USER ALL=NOPASSWD:/usr/bin/docker
	EOF
  chmod 440 /etc/sudoers.d/$USER

  cat > /etc/ssmtp/ssmtp.conf <<-EOF
	mailhub=localhost:35
	root=admin@jast.ru
	rewriteDomain=cloud1.el-f.pro
	hostname=cloud1.el-f.pro
	EOF
}


[ -d $ROOT ] || mkdir -p $ROOT
chown $USER:www-data $ROOT
chmod ug+w $ROOT

if [ -f $KEY0 ] ; then
  cat $KEY0 | head -1 > /home/$USER/$ADMIN.pub
elif [ -f $KEY1 ] ; then
  cat $KEY1 | head -1 > /home/$USER/$ADMIN.pub
else
  echo "WARNING: ssh key not found"
fi
echo $ADMIN > /home/$USER/admin.name

su - $USER
cd

[ -d gitolite-ci ] || git clone https://github.com/LeKovr/gitolite-ci.git
. gitolite-ci/remote/init.sh < admin.name
