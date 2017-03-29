#!/bin/bash


# Example:
# NODEBB_REDIS_PASSWORD=asd123 NODEBB_REDIS_DB=0 ./setup-redis.sh

if [[ -z "$NODEBB_REDIS_PASSWORD" ]]; then
    echo "Please add environment variable NODEBB_REDIS_PASSWORD"
    exit 1
fi
if [[ -z "$NODEBB_REDIS_DB" ]]; then
    NODEBB_REDIS_DB=0
fi
if [[ -z "$NODEBB_EXPOSE_PORT" ]]; then
    NODEBB_EXPOSE_PORT=4567
fi


SAFE_NODEBB_REDIS_PASSWORD=$(echo $NODEBB_REDIS_PASSWORD | sed -e 's/[\/$*.^|&]/\\&/g')
cat docker-compose.yml.tpl | \
    sed "s|<DATABASE>|redis|g" | \
    sed "s|<EXPOSEPORT>|$NODEBB_EXPOSE_PORT|g" | \
    sed "s|<REDISPASS>|$SAFE_NODEBB_REDIS_PASSWORD|g" \
    > docker-compose.yml


mkdir -p data/redis
git clone https://github.com/NodeBB/NodeBB.git data/nodebb


docker-compose up -d --build redis nodebb
docker-compose run --rm nodebb npm install
docker-compose run --rm nodebb ./nodebb setup \
    --database=redis \
    --redis:host=redis \
    --redis:password="$NODEBB_REDIS_PASSWORD" \
    --redis:database="$NODEBB_REDIS_DB" \
    "$@"
docker-compose run redis redis-cli -h redis -a "$NODEBB_REDIS_PASSWORD" save

docker-compose stop