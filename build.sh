#!/bin/bash

# build.sh

VERSION="v0.0.0";
OSNAME=""

# Simplified - assumes all 64 bit for now
case "$OSTYPE" in
  linux*)   OSNAME="Linux64" ;;
  Linux*)   OSNAME="Linux64" ;;
  darwin*)  OSNAME="Mac" ;;
  Darwin*)  OSNAME="Mac" ;;
  win*)     OSNAME="Windows64" ;;
  Win*)     OSNAME="Windows64" ;;
esac

if [ "$OSNAME" == "" ]; then
  echo "Unknown operating system from $OSTYPE"
  exit 1
fi

# creates a all build of the n3 components and combined into
# ZIP files for release.

# Repositories:
#   * DC-UI
#   * n3-client
#   * n3-transport

echo "N3BUILD: Start - Building n3-$OSNAME-$VERSION.zip"

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

echo "N3BUILD: Creating N3-WEB @ $N3WEB_BRANCH"
go get github.com/nsip/n3-web || true
cd $GOPATH/src/github.com/nsip/n3-web
git checkout $N3WEB_BRANCH
git pull
cd server/n3w
go get
echo "N3BUILD: building N3-WEB"
go build -ldflags="$LDFLAGS"
rsync -av * $ORIGINALPATH/build/
rm $ORIGINALPATH/build/server.go

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
mkdir -p build/publilc/dc-ui
rsync -av ../DC-UI/dist/spa-mat/* build/publilc/dc-ui/

echo "N3BUILD: Creating DC-Dynamic files @ $DCDYNAMIC_BRANCH"
cd ../dc-dynamic
git checkout $DCDYNAMIC_BRANCH
git pull
npm install
./node_modules/.bin/quasar build
rsync -av src/assets dist/spa-mat/
cd $ORIGINALPATH
mkdir -p build/publilc/dc-dynamic
rsync -av ../dc-dynamic/dist/spa-mat/* build/publilc/dc-dynamic/

#echo "N3BUILD: Generating/Updating WWW files"
#rsync -av www/* build/www/
#
#echo "N3BUILD: Complete"
