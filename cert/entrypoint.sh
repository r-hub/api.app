#! /bin/sh

mkdir -p /etc/letsencrypt/live/api.r-hub.io

cp /api.r-hub.io+3.pem /etc/letsencrypt/live/api.r-hub.io/fullchain.pem
cp /api.r-hub.io+3-key.pem /etc/letsencrypt/live/api.r-hub.io/privkey.pem

find /etc/letsencrypt
