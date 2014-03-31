#
# Use:
# ssh -t root@example.com 'bash -s' < system-init.sh

# host user - files owner
USER=git

# git admin
ADMIN=$1
[[ "$ADMIN" ]] || ADMIN=op


# Cloud host default key
KEY0=/root/.ssh/authorized_keys

# Dish host  default key
KEY1=/home/op/.ssh/authorized_keys


apt-get -y install git-core moreutils

grep -qe "^$USER:" /etc/passwd || {
  useradd -m $USER
  usermod -L $USER

  echo "$USER ALL=NOPASSWD:/usr/bin/supervisorctl" > /etc/sudoers.d/$USER
  chmod 400 /etc/sudoers.d/$USER
}

if [ -f $KEY0 ] ; then
  cp $KEY0 /home/$USER/$ADMIN.pub
elif [ -f $KEY1 ] ; then
  cp $KEY1 /home/$USER/$ADMIN.pub
else
  echo "WARNING: ssh key not found"
fi
su - $USER
cd

[ -d gitolite-ci ] || git clone git@github.com:LeKovr/gitolite-ci.git
. gitolite-ci/remote/init.sh $ADMIN
