
# Wait for  DB to be ready
while true
do
    echo "waiting for DB"
    if curl -s elasticsearch:9200; then break; fi
    sleep 1
done

echo "adding mapping"
curl -XPUT elasticsearch:9200/package \
     -d @/seed/elastic/mapping.json \
     -H "Content-Type: application/json"
