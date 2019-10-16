#!/bin/bash

set -e

# build.sh

VERSION="v0.0.4";
OSNAME="$1"

DCUI_BRANCH="n3w-integration"
DCDYNAMIC_BRANCH="n3w-integration"
N3WEB_BRANCH="master"
DCCURRICULUMSERVICE_BRANCH="master"
export GO111MODULE=off

ORIGINALPATH=`pwd`

GOARCH=amd64
LDFLAGS="-s -w"
export GOARCH

# Simplified - assumes all 64 bit for now
if [ "$OSNAME" == "" ]; then
	case "$OSTYPE" in
	  linux*)   OSNAME="Linux64" ;;
	  Linux*)   OSNAME="Linux64" ;;
	  darwin*)  OSNAME="Mac" ;;
	  Darwin*)  OSNAME="Mac" ;;
	  win*)     OSNAME="Windows64" ;;
	  Win*)     OSNAME="Windows64" ;;
	esac
fi

if [ "$OSNAME" == "" ]; then
  echo "Unknown operating system from $OSTYPE"
  exit 1
fi

NATS_BASE="https://github.com/nats-io/nats-streaming-server/releases/download/v0.16.2/"
NATS_FILE=""
case "$OSNAME" in
  Linux64) NATS_FILE="nats-streaming-server-v0.16.2-linux-amd64.zip" ;;
  Mac) NATS_FILE="nats-streaming-server-v0.16.2-darwin-amd64.zip" ;;
  Windows64) NATS_FILE="nats-streaming-server-v0.16.2-windows-amd64.zip" ;;
esac

GOOS=""
case "$OSNAME" in
  Linux64) GOOS="linux" ;;
  Mac) GOOS="darwin" ;;
  Windows64) GOOS="windows" ;;
esac
export GOOS

EXT=""
case "$OSNAME" in
  Windows64) EXT=".exe" ;;
esac

if [ "$NATS_FILE" == "" ]; then
  echo "Unknown NATS File Download from $OSNAME"
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


echo "N3BUILD NOTE: removing existing builds"
rm -rf build

mkdir -p build

echo "N3BUILD: Getting NATS server"
curl -o build/nats.zip -L $NATS_BASE$NATS_FILE
cd build
unzip nats.zip
mv nats-streaming-server-v*/nats-streaming-server$EXT .
rm -Rf nats-streaming-server-v*
rm nats.zip
cd $ORIGINALPATH


# think the logic is this...need to get badger and then
# set the correct version for badger itself and the
# problem dependency...
# otherwise the go get for n3 pulls in the wrong version
# of badger (2.0 as oppsed to 1.6)
#
# think the flow below will do it, once packages are in place
# the go get for n3w will not upgrade them.

echo "Fetching badger"
go get github.com/dgraph-io/badger/...
cd $GOPATH/src/github.com/dgraph-io/badger
echo "Forcing badger to v1.6"
git checkout 329b6828fc708b90d01faeaf2b83fb6d1c5138ef

# this lib should have been brought in by the go get of badger
# but needs to be at a certain version
echo "Forcing badger dependency version change"
cd $GOPATH/src/github.com/AndreasBriese/bbloom
git checkout e2d15f34fcf99d5dbb871c820ec73f710fca9815

echo "N3BUILD: Creating N3-WEB @ $N3WEB_BRANCH"
go get github.com/nsip/n3-web || true
cd $GOPATH/src/github.com/nsip/n3-web
git checkout $N3WEB_BRANCH
git pull
cd server/n3w
go get
cd $GOPATH/src/github.com/nsip/vvmap
git pull
cd $GOPATH/src/github.com/nsip/n3-web/server/n3w
echo "N3BUILD: building N3-WEB"
go clean
go build -ldflags="$LDFLAGS"
rsync -av * $ORIGINALPATH/build/
rm $ORIGINALPATH/build/server.go || true
rm -Rf $ORIGINALPATH/build/contexts || true
cd $ORIGINALPATH

echo "N3BUILD: Creating dc-curriculum-service @ $DCCURRICULUMSERVICE_BRANCH"
go get github.com/nsip/dc-curriculum-service || true
cd $GOPATH/src/github.com/nsip/dc-curriculum-service
git pull
git checkout $DCCURRICULUMSERVICE_BRANCH
git pull
go get
echo "N3BUILD: building dc-curriculum-service"
echo "GOOS $GOOS"
go build -ldflags="$LDFLAGS"
rsync -av dc-curriculum-service$EXT $ORIGINALPATH/build/
rsync -av db $ORIGINALPATH/build/
rsync -av nsw $ORIGINALPATH/build/
rsync -av gql $ORIGINALPATH/build/
cd $ORIGINALPATH

echo "N3BUILD: Creating DC-UI files @ $DCUI_BRANCH"
cd ../DC-UI
git pull
git checkout $DCUI_BRANCH
git pull
npm install
./node_modules/.bin/quasar build
rsync -av src/assets dist/spa-mat/
cd $ORIGINALPATH
mkdir -p build/public/dc-ui
rsync -av ../DC-UI/dist/spa-mat/* build/public/dc-ui/

echo "N3BUILD: Creating DC-Dynamic files @ $DCDYNAMIC_BRANCH"
cd ../dc-dynamic
git pull
git checkout $DCDYNAMIC_BRANCH
git pull
npm install
./node_modules/.bin/quasar build
rsync -av src/assets dist/spa-mat/
cd $ORIGINALPATH
mkdir -p build/public/dc-dynamic
rsync -av ../dc-dynamic/dist/spa-mat/* build/public/dc-dynamic/

echo "N3BUILD: Generating ZIP"
cd build
zip -qr ../n3-$OSNAME-$VERSION.zip *

echo "N3BUILD: Complete - n3-$OSNAME-$VERSION.zip"
