#!/bin/bash

# git admin user
read KEYFILE

echo "Setup gitolite for admin key $KEYFILE"
echo "in dir $PWD"

[ -d gitolite ] || git clone https://github.com/sitaramc/gitolite.git
[ -d bin ] || mkdir bin
gitolite/install -to $PWD/bin

bin/gitolite setup -pk $KEYFILE

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
