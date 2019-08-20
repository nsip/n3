#!/bin/sh

# build.sh

# creates a all build of the n3 components and combined into
# ZIP files for release.

# Repositories:
#   * DC-UI
#   * n3-client
#   * n3-transport

echo "N3BUILD: Start"

DCUI_BRANCH="master"
N3CLIENT_BRANCH="privacy-dev"
N3TRANSPORT_BRANCH="qing-privacy-dev"
export GO111MODULE=off

set -e
ORIGINALPATH=`pwd`

echo "N3BUILD NOTE: removing existing builds"
rm -rf build

mkdir -p build
mkdir -p build/www
mkdir -p build/n3-client
mkdir -p build/n3-transport

echo "N3BUILD: Creating DC-UI files @ $DCUI_BRANCH"
cd ../DC-UI
git checkout $DCUI_BRANCH
git pull
npm install
./node_modules/.bin/quasar build
cd $ORIGINALPATH
rsync -av ../DC-UI/dist/spa-mat/* build/www/dc/

echo "N3BUILD: Creating N3-Client @ $N3CLIENT_BRANCH"
go get github.com/nsip/n3-client || true
cd $GOPATH/src/github.com/nsip/n3-client
git checkout $N3CLIENT_BRANCH
git pull
./build.sh
cd $ORIGINALPATH
rsync -av $GOPATH/src/github.com/nsip/n3-client/build/* build/n3-client/
# XXX name for this www code?
rsync -av $GOPATH/src/github.com/nsip/n3-client/www/* build/www/service/

echo "N3BUILD: Creating N3-Transport @ $N3TRANSPORT_BRANCH"
go get github.com/nsip/n3-transport || true
cd $GOPATH/src/github.com/nsip/n3-transport
git checkout $N3TRANSPORT_BRANCH
git pull
mkdir build
./build.sh
cd $ORIGINALPATH
rsync -av $GOPATH/src/github.com/nsip/n3-transport/build/* build/

echo "N3BUILD: Generating/Updating WWW files"
rsync -av www/* build/www/

echo "N3BUILD: Complete"
