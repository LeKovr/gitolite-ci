#!/bin/bash

[ -d gitolite ] || git clone git://github.com/sitaramc/gitolite
mkdir -p $HOME/bin
gitolite/install -to $HOME/bin

cp gitolite-ci/remote/hooks/* .gitolite/hooks/common/

bin/gitolite setup -pk op.pub

#bin/gitolite setup --hooks-only
sed -i "s/\(GIT_CONFIG_KEYS *=> *\)''/\1'.*'/" .gitolite.rc

