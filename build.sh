#!/bin/sh

# build.sh

# creates a all build of the n3 components and combined into
# ZIP files for release.

# Repositories:
#   * DC-UI
#   * n3-client
#   * n3-transport

set -e
CWD=`pwd`

echo "removing existing builds"
rm -rf build

mkdir -p build
mkdir -p build/www

echo "Creating DC-UI files"
cd ../DC-UI
npm install
./node_modules/.bin/quasar build
cd ../n3
rsync -av ../DC-UI/dist/spa-mat/* build/www/
