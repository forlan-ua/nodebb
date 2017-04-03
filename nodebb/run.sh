#!/bin/bash


chown -R www-data:www-data /nodebb


install_packages() {
    echo "Install packages"
}


install_themes() {
    echo "Install themes"
}

setup_node_modules() {
    cd /nodebb/core
    exec sudo -u www-data npm install
}

setup_with_redis() {
    exec sudo -u www-data ./nodebb setup \
        --database=redis \
        --redis:host=redis \
        --redis:port=$NODEBB_REDIS_PORT \
        --redis:password="$NODEBB_REDIS_PASSWORD" \
        --redis:database="$NODEBB_REDIS_DB" \
        --url="$NODEBB_URL" \
        --admin:username="$NODEBB_ADMIN_USERNAME" \
        --admin:password="$NODEBB_ADMIN_PASSWORD"
}

setup_with_mongo() {
    exec sudo -u www-data ./nodebb setup \
        --database=mongo \
        --mongo:host=mongo \
        --mongo:port=$NODEBB_MONGO_PORT \
        --mongo:username="$NODEBB_MONGO_USER" \
        --mongo:password="$NODEBB_MONGO_PASSWORD" \
        --mongo:database="$NODEBB_MONGO_DB" \
        --url="$NODEBB_URL"  \
        --admin:username="$NODEBB_ADMIN_USERNAME" \
        --admin:password="$NODEBB_ADMIN_PASSWORD"
}


if [ "$NODEBB_DATABASE" = "redis" ]; then
    if [ -z "$NODEBB_REDIS_PASSWORD" ]; then
        echo "You have to setup redis password"
        exit 1
    fi

    if [ "$1" = "setup" ]; then
        setup_node_modules
        setup_with_redis

        install_packages
        install_themes

        exit 0
    elif [ "$1" = "pre-setup" ]; then
        exit 0
    fi
elif [ "$NODEBB_DATABASE" = "mongo" ]; then
    if [ -z "$NODEBB_MONGO_USER" ]; then
        echo "You have to setup mongo user"
        exit 1
    fi
    if [ -z "$NODEBB_MONGO_PASSWORD" ]; then
        echo "You have to setup mongo password"
        exit 1
    fi

    if [ "$1" = "setup" ]; then
        setup_node_modules
        setup_with_mongo

        install_packages
        install_themes

        exit 0
    elif [ "$1" = "pre-setup" ]; then
        apt-get update
        apt-get install -y mongodb-clients

        mongo "mongo-setup:$NODEBB_MONGO_PORT/$NODEBB_MONGO_DB" --eval "db.createUser({user: '$NODEBB_MONGO_USER', pwd: '$NODEBB_MONGO_PASSWORD', roles: [{role: 'readWrite', db: '$NODEBB_MONGO_DB'}]});"
    fi
else
    echo "Unsupported database $NODEBB_DATABASE"
    exit 1
fi

cd /nodebb/core
exec sudo -u www-data node app.js