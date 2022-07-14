#! /bin/sh

mkdir -p /etc/letsencrypt/live/api.r-hub.io
mkdir -p /etc/letsencrypt/live/search.r-pkg.org

cp /api.r-hub.io+3.pem /etc/letsencrypt/live/api.r-hub.io/fullchain.pem
cp /api.r-hub.io+3-key.pem /etc/letsencrypt/live/api.r-hub.io/privkey.pem

cp /search.r-pkg.org+3.pem /etc/letsencrypt/live/search.r-pkg.org/fullchain.pem
cp /search.r-pkg.org+3-key.pem /etc/letsencrypt/live/search.r-pkg.org/privkey.pem

find /etc/letsencrypt
