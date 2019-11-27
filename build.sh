#!/bin/bash

set -e

# build.sh

OSNAME="$1"

if [ "$OSNAME" == "help" ]; then
  echo "Build N3"
  echo " - Requirements:"
  echo "    . Access to nsip github"
  echo "    . go - versino X"
  echo "    . Utilities - git, zip, unzip, curl"
  echo " - Version is detected using tools/release and tags"
  echo " - OS is auto detect, or can be provided:"
  echo "    . Linux64"
  echo "    . Mac"
  echo "    . Windows64"
  echo ""
  exit 1
fi

DEPENDS=("git" "zip" "unzip" "curl")
for b in ${DEPENDS[@]}; do
  if ! [ -x "$(command -v $b)" ]; then
        echo "Missing utilitiy: $b"
        exit 1
  fi
done

go get gopkg.in/cheggaaa/pb.v1
cd tools; go build release.go; cd ..

VERSION="$(./tools/release n3 version)"

if [ -z "$VERSION" ]; then
  echo "Can not determine version"
  exit 1
fi
echo "N3BUILD: VERSION=$VERSION"

# JS Applications to download
DCDYNAMIC=https://github.com/nsip/dc-dynamic/releases/download/v1.0.1/dc-dynamic-v1_0_1.zip
DCUI=https://github.com/nsip/DC-UI/releases/download/v1.1.0/DC-UI-v1_1_0.zip

# Specific branches
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

echo "N3BUILD: Start - Building n3-$OSNAME-$VERSION"

echo "N3BUILD NOTE: removing existing builds"
rm -rf build

mkdir -p build

echo "N3BUILD: Static Code"
cd $ORIGINALPATH
mkdir -p build/public/dc-dynamic
cd build/public/dc-dynamic
curl -o temp.zip -L $DCDYNAMIC
unzip temp.zip
rm temp.zip
mkdir -p build/public/DC-UI
cd build/public/DC-UI
curl -o temp.zip -L $DCDYNAMIC
unzip temp.zip
rm temp.zip
cd $PWD
cd $ORIGINALPATH


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
go get github.com/AndreasBriese/bbloom
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
rm load$EXT || true
go build -ldflags="$LDFLAGS"
go build -ldflags="$LDFLAGS" -o load$EXT tools/load.go
rsync -av * $ORIGINALPATH/build/
rm $ORIGINALPATH/build/server.go || true
rm -Rf $ORIGINALPATH/build/contexts || true
cd $ORIGINALPATH

echo "N3BUILD: Creating dc-curriculum-service @ $DCCURRICULUMSERVICE_BRANCH"
go get github.com/nsip/dc-curriculum-service || true
cd $GOPATH/src/github.com/nsip/dc-curriculum-service
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

echo "N3BUILD: Generating ZIP"
cd build
rm ../n3-$OSNAME-$VERSION.zip || true
zip -qr ../n3-$OSNAME-$VERSION.zip *

echo "N3BUILD: Complete - n3-$OSNAME-$VERSION.zip"

echo "If happy with zip, run the following release command"
echo " ./tools/release n3 n3-$OSNAME.zip n3-$OSNAME-$VERSION.zip"
