#!/bin/bash

# build.sh

VERSION="v0.0.0";

# creates a all build of the n3 components and combined into
# ZIP files for release.

# Repositories:
#   * DC-UI
#   * n3-client
#   * n3-transport

echo "N3BUILD: Start"

DEPENDS=("git" "zip" "unzip" "npm" "node")
for b in ${DEPENDS[@]}; do
  if ! [ -x "$(command -v $b)" ]; then
        echo "Missing utilitiy: $b"
        exit 1
  fi
done

DCUI_BRANCH="n3w-integration"
DCDYNAMIC_BRANCH="n3w-integration"
N3WEB_BRANCH="master"
DCCURRICULUMSERVICE="master"
export GO111MODULE=off

set -e
ORIGINALPATH=`pwd`

GOARCH=amd64
LDFLAGS="-s -w"

echo "N3BUILD NOTE: removing existing builds"
rm -rf build

mkdir -p build
mkdir -p build/Mac
mkdir -p build/Linux64
mkdir -p build/Windows64

echo "N3BUILD: Creating N3-WEB @ $N3WEB_BRANCH"
go get github.com/nsip/n3-web || true
cd $GOPATH/src/github.com/nsip/n3-web
git checkout $N3WEB_BRANCH
git pull
cd server/n3w
go get

echo "N3BUILD: building N3-WEB Mac"
GOOS="darwin" GOARCH="$GOARCH" go build -ldflags="$LDFLAGS"
rsync -av * $ORIGINALPATH/build/Mac/
rm $ORIGINALPATH/build/Mac/server.go

echo "N3BUILD: building N3-WEB Linux64"
GOOS="linux" GOARCH="$GOARCH" go build -ldflags="$LDFLAGS"
rsync -av * $ORIGINALPATH/build/Linux64/
rm $ORIGINALPATH/build/Linux64/server.go

echo "N3BUILD: building N3-WEB Windows64"
GOOS="windows" GOARCH="$GOARCH" go build -ldflags="$LDFLAGS"
rsync -av * $ORIGINALPATH/build/Windows64/
rm $ORIGINALPATH/build/Windows64/server.go

cd $ORIGINALPATH

# XXX Get natserver

echo "N3BUILD: Creating DC-UI files @ $DCUI_BRANCH"
cd ../DC-UI
git checkout $DCUI_BRANCH
git pull
npm install
./node_modules/.bin/quasar build
rsync -av src/assets dist/spa-mat/
cd $ORIGINALPATH
mkdir -p build/Mac/publilc/dc-ui
mkdir -p build/Linux64/publilc/dc-ui
mkdir -p build/Windows64/publilc/dc-ui
rsync -av ../DC-UI/dist/spa-mat/* build/Mac/publilc/dc-ui/
rsync -av ../DC-UI/dist/spa-mat/* build/Linux64/publilc/dc-ui/
rsync -av ../DC-UI/dist/spa-mat/* build/Windows64/publilc/dc-ui/

echo "N3BUILD: Creating DC-Dynamic files @ $DCDYNAMIC_BRANCH"
cd ../dc-dynamic
git checkout $DCDYNAMIC_BRANCH
git pull
npm install
./node_modules/.bin/quasar build
rsync -av src/assets dist/spa-mat/
cd $ORIGINALPATH
mkdir -p build/Mac/publilc/dc-dynamic
mkdir -p build/Linux64/publilc/dc-dynamic
mkdir -p build/Windows64/publilc/dc-dynamic
rsync -av ../dc-dynamic/dist/spa-mat/* build/Mac/publilc/dc-dynamic/
rsync -av ../dc-dynamic/dist/spa-mat/* build/Linux64/publilc/dc-dynamic/
rsync -av ../dc-dynamic/dist/spa-mat/* build/Windows64/publilc/dc-dynamic/

#echo "N3BUILD: Generating/Updating WWW files"
#rsync -av www/* build/www/
#
#echo "N3BUILD: Complete"
