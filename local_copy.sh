#!/bin/sh

mkdir -p /var/www/html/nias
rsync -av build/*.zip /var/www/html/nias/
