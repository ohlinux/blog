#!/usr/bin/env bash

if [ ! -f install.sh ]; then
    echo 'install.sh must be run within its container folder' 1>&2
    exit 1
fi

#autoweb_CMD="/usr/bin/autoweb"
CURDIR=`pwd`
export GOPATH="$CURDIR"
export GOBIN="$GOPATH/bin"
#cat << EOF > $autoweb_CMD
##!/usr/bin/env bash
#export autoweb_CMD="$autoweb_CMD"
#export autoweb_ROOT="$CURDIR"
#$CURDIR/bin/autoweb
#EOF

#chmod +x $autoweb_CMD

gofmt -tabs=false -tabwidth=4 -w src

go install autoweb

echo 'Install finished!!!'
echo 'Please use ./bin/autoweb -h'
