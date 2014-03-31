#!/bin/bash

PRJ=$1
CFG=conf/gitolite.conf
ROOT=/home/app/srv

ADMIN="op"
WATCHERS="jean@jast.ru"

[[ "$PRJ" ]] || { echo "Usage: $0 <PROGECT_NAME>" ; exit 1 ; }

if [ -d gitolite-admin ] ; then
  pushd gitolite-admin
  git pull
else
  git clone git@localhost:gitolite-admin
  pushd gitolite-admin
fi

grep $PRJ $CFG || cat >> $CFG <<EOF

repo    $PRJ
        RW+     =   $ADMIN
        config hooks.mailinglist = "$WATCHERS"
        config hooks.emailprefix = "[$PRJ]"
        config hooks.distropath  = "$ROOT/$PRJ"
EOF

git commit -am "$PRJ project added"
git push

popd

cat <<EOF
Project $PRG setup complete.
Clone it via:
  git clone git@localhost:$PRJ
EOF

