#!/bin/bash

# git admin user
ADMIN=$1

echo "Setup for user $ADMIN"

[ -d gitolite ] || git clone https://github.com/sitaramc/gitolite.git
mkdir -p $HOME/bin
gitolite/install -to $HOME/bin

cp gitolite-ci/remote/hooks/* .gitolite/hooks/common/

bin/gitolite setup -pk $ADMIN.pub

#bin/gitolite setup --hooks-only
sed -i "s/\(GIT_CONFIG_KEYS *=> *\)''/\1'.*'/" .gitolite.rc

