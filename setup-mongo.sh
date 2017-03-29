#!/bin/bash


# Example:
# NODEBB_MONGO_USER=nodebb NODEBB_MONGO_PASSWORD=asd123 NODEBB_MONGO_DB=nodebb ./setup-mongo.sh

if [[ -z "$NODEBB_MONGO_USER" ]]; then
    echo "Please add environment variable NODEBB_MONGO_USER"
    exit 1
fi
if [[ -z "$NODEBB_MONGO_PASSWORD" ]]; then
    echo "Please add environment variable NODEBB_MONGO_PASSWORD"
    exit 1
fi
if [[ -z "$NODEBB_MONGO_DB" ]]; then
    NODEBB_MONGO_DB=nodebb
fi
if [[ -z "$NODEBB_EXPOSE_PORT" ]]; then
    NODEBB_EXPOSE_PORT=4567
fi


cat docker-compose.yml.tpl | \
    sed "s|<DATABASE>|mongo|g" \
    sed "s|<EXPOSEPORT>|$NODEBB_EXPOSE_PORT|g" | \
    > docker-compose.yml


mkdir -p data/mongo
git clone https://github.com/NodeBB/NodeBB.git data/nodebb

docker-compose up -d mongo-setup
while true; do
    res=$(docker-compose run --rm mongo-setup mongo mongo-setup/$NODEBB_MONGO_DB --eval "db.getName()")
    for test in $res; do
        test2=$(echo "$test" | grep "$NODEBB_MONGO_DB")
        if [ "${#test}" -le "$((${#NODEBB_MONGO_DB} + 1))" ] && [ -n "$test2" ]; then break 2; fi
    done;
    sleep 1
done
docker-compose run --rm mongo-setup mongo mongo-setup/$NODEBB_MONGO_DB --eval "db.createUser({user: '$NODEBB_MONGO_USER', pwd: '$NODEBB_MONGO_PASSWORD', roles: [{role: 'readWrite', db: '$NODEBB_MONGO_DB'}]});"
docker-compose stop mongo-setup

docker-compose up -d --build mongo nodebb
docker-compose run --rm nodebb npm install
docker-compose run --rm nodebb ./nodebb setup \
    --database=mongo \
    --mongo:host=mongo \
    --mongo:username="$NODEBB_MONGO_USER" \
    --mongo:password="$NODEBB_MONGO_PASSWORD" \
    --mongo:database="$NODEBB_MONGO_DB" \
    "$@"

docker-compose stop