#!/bin/bash

PRJ=$1
CFG=conf/gitolite.conf
APPROOT=/home/app/srv

. gitolite-ci.conf

[[ "$PRJ" ]] || { echo "Usage: $0 <PROGECT_NAME>" ; exit 1 ; }

LOCALROOT=sites/$CFGHOST
[ -d $LOCALROOT ] || mkdir -p $LOCALROOT
pushd $LOCALROOT

if [ -d gitolite-admin ] ; then
  pushd gitolite-admin
  git pull
else
  git clone git@$CFGHOST:gitolite-admin
  pushd gitolite-admin
fi

grep -q "repo +$PRJ" $CFG || cat >> $CFG <<EOF

repo    $PRJ
        RW+     =   $ADMIN
        config hooks.mailinglist  = "$WATCHERS"
        config hooks.emailprefix  = "[$PRJ]"
        config hooks.deployroot   = "$APPROOT/$PRJ"
        config hooks.deploybranch = "1"
EOF

git commit -am "$PRJ project added"
git push

popd

cat <<EOF
Project $PRG setup complete.
Clone it via:
  git clone git@$CFGHOST:$PRJ
EOF

