#!/bin/bash

# git admin user
read ADMIN

echo "Setup for user $ADMIN"

[ -d gitolite ] || git clone https://github.com/sitaramc/gitolite.git
mkdir -p $HOME/bin
gitolite/install -to $HOME/bin

bin/gitolite setup -pk $ADMIN.pub

cp gitolite-ci/remote/hooks/* .gitolite/hooks/common/
bin/gitolite setup --hooks-only

sed -i "s/\(GIT_CONFIG_KEYS *=> *\)''/\1'.*'/" .gitolite.rc

cat <<EOF
Congratulations!
Your CI system on gitolite is ready
Use project-add.sh to add projects

EOF
