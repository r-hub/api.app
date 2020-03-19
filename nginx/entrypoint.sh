
set -e

wait-for rversions:3000 -- nginx -g "daemon off;"
