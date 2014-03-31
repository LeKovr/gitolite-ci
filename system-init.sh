#
# Use:
# ssh -t root@example.com 'bash -s' < system-init.sh

USER=git
KEY=/root/.ssh/authorized_keys

apt-get -y install git-core moreutils

grep -qe "^$USER:" /etc/passwd || {
  useradd -m $USER
  usermod -L $USER

  echo "$USER ALL=NOPASSWD:/usr/bin/supervisorctl" > /etc/sudoers.d/$USER
  chmod 400 /etc/sudoers.d/$USER
}

cp $KEY /home/$USER/op.pub

su - $USER
cd

#[ -d gitolite-ci ] || git clone git://github.com/lekovr/gitolite-ci
#. gitolite-ci/remote/init.sh

