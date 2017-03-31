#!/bin/bash


mkdir -p data/redis
mkdir -p data/custom-static
mkdir -p data/plugins
mkdir -p data/themes
git clone https://github.com/NodeBB/NodeBB.git data/nodebb

docker-compose run --rm nodebb-setup ./run.sh pre-setup
docker-compose stop

docker-compose run --rm nodebb-web ./run.sh setup
docker-compose stop