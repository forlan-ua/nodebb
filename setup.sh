#!/bin/bash

if [ -z "$NODEBB_DOCKER_COMPOSE_CONFIG" ]; then
    NODEBB_DOCKER_COMPOSE_CONFIG="-f docker-compose.yml"
fi

if [ -z "$NODEBB_CORE_DIR" ]; then
    NODEBB_CORE_DIR=".data/nodebb"
fi

if [ ! -e "$NODEBB_CORE_DIR" ]; then
    git clone https://github.com/NodeBB/NodeBB.git $NODEBB_CORE_DIR
    git checkout -b v1.x.x --track origin/v1.x.x
fi

eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG run --rm nodebb-setup pre-setup"
eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG stop"

eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG run --rm nodebb-web setup"
eval "docker-compose $NODEBB_DOCKER_COMPOSE_CONFIG stop"