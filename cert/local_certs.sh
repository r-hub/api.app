#!/bin/bash

set -e

cd cert

# This needs mkcert: https://github.com/FiloSottile/mkcert#linux
# Run this to install it on Linux:
# curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64"
# chmod +x mkcert-v*-linux-amd64
# sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert

mkcert -install

if ! ls "api.r-hub.io+3-key.pem" "api.r-hub.io+3.pem" >/dev/null 2>&1; then
    mkcert api.r-hub.io localhost 127.0.0.1 ::1
fi

docker volume create api_certbot-etc || true

docker build -t rhub-nopush/api-local-certs:0.0.1 .

docker run -v api_certbot-etc:/etc/letsencrypt rhub-nopush/api-local-certs:0.0.1 \
       sh -c /entrypoint.sh

# To test add this to /etc/hosts:
# 127.0.0.1 api.r-hub.io
# and then you can run
# curl https://api.r-hub.io/rversions/r-release
