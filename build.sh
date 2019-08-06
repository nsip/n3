#!/bin/sh

# build.sh

# creates a all build of the n3 components and combined into
# ZIP files for release.

# Repositories:
#   * DC-UI
#   * n3-client
#   * n3-transport

set -e
ORIGINALPATH=`pwd`

echo "removing existing builds"
rm -rf build

mkdir -p build
mkdir -p build/www
mkdir -p build/n3-client
mkdir -p build/n3-transport

echo "Creating DC-UI files"
cd ../DC-UI
npm install
./node_modules/.bin/quasar build
cd $ORIGINALPATH
rsync -av ../DC-UI/dist/spa-mat/* build/www/

echo "Creating N3-Client"
cd $GOPATH/src/github.com/nsip/n3-client
./build.sh
cd $ORIGINALPATH
rsync -av $GOPATH/src/github.com/nsip/n3-client/build/* build/n3-client/

echo "Creating N3-Transport"
cd $GOPATH/src/github.com/nsip/n3-transport
./build.sh
cd $ORIGINALPATH
rsync -av $GOPATH/src/github.com/nsip/n3-transport/build/* build/n3-transport/
