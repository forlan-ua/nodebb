#!/bin/bash

if [ -z "$NODEBB_DOCKER_COMPOSE_CONFIG" ]; then
    NODEBB_DOCKER_COMPOSE_CONFIG="-f docker-compose.yml"
fi

if [ -z "$NODEBB_CORE_DIR" ]; then
    NODEBB_CORE_DIR=".data/nodebb"
fi

git clone https://github.com/NodeBB/NodeBB.git $NODEBB_CORE_DIR

eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG run --rm nodebb-setup pre-setup"
eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG stop"

eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG run --rm nodebb-web setup"
eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG stop"