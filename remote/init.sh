#!/bin/bash

# git admin user
read ADMIN

echo "Setup gitolite for user $ADMIN"

[ -d gitolite ] || git clone https://github.com/sitaramc/gitolite.git
mkdir -p $HOME/bin
gitolite/install -to $HOME/bin

bin/gitolite setup -pk $ADMIN.pub

for f in gitolite-ci/remote/hooks/* ; do 
  name=${f##*/}
  [ -e .gitolite/hooks/common/$name ] || ln -s $PWD/$f .gitolite/hooks/common/$name
done

bin/gitolite setup --hooks-only

sed -i "s/\(GIT_CONFIG_KEYS *=> *\)''/\1'.*'/" .gitolite.rc

cat <<EOF
Congratulations!
Your CI system on gitolite is ready
Run project-add.sh locally to add projects on server

EOF
