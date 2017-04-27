#!/bin/bash


chown -R www-data:www-data /nodebb


install_plugins() {
    sudo -u www-data \
        find /nodebb/plugins \
            -maxdepth 1 \
            -mindepth 1 \
            -type d \
            -exec sh -c 'cd /nodebb/core && rm -rf /nodebb/core/node_modules/$(basename {}) && npm install {} && ./nodebb activate $(basename {})' \;
}

install_themes() {
    sudo -u www-data \
        find /nodebb/themes \
            -maxdepth 1 \
            -mindepth 1 \
            -type d \
            -exec sh -c 'cd /nodebb/core && rm -rf /nodebb/core/node_modules/$(basename {}) && npm install {} && ./nodebb activate $(basename {})' \;
}

setup_node_modules() {
    cd /nodebb/core && \
        sudo -u www-data npm install --production
    if [ -z $(cat /nodebb/core/app.js | grep PATCHED) ]; then
        echo "// PATCHED" >> /nodebb/core/app.js
        echo "process.send = process.send || function(data) {winston.warn(data); if (data&&data.action=='restart') {process.exit(1)}};" >> /nodebb/core/app.js
    fi
}

setup_with_redis() {
    cd /nodebb/core && \
        sudo -u www-data ./nodebb setup \
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
    cd /nodebb/core && \
        sudo -u www-data ./nodebb setup \
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


if [ "$1" = "exit" ]; then
    exit 0
elif [ "$1" = "bash" ];then
    /bin/bash
    exit 0
elif [ "$1" = "update-nodebb" ];then
    cd /nodebb/core

    git ckeckout -- app.js
    git pull

    setup_node_modules
    install_plugins
    install_themes
    node /nodebb/core/nodebb upgrade
    exit 0
elif [ "$1" = "install-plugins" ]; then
    install_plugins
    exit 0
elif [ "$1" = "install-themes" ]; then
    install_themes
    exit 0
elif [ "$1" = "build" ]; then
    node /nodebb/core/nodebb build
    exit 0
elif [ "$1" = "upgrade" ]; then
    node /nodebb/core/nodebb upgrade
    exit 0
fi

if [ "$NODEBB_DATABASE" = "redis" ]; then
    if [ -z "$NODEBB_REDIS_PASSWORD" ]; then
        echo "You have to setup redis password"
        exit 1
    fi

    if [ "$1" = "setup" ]; then
        sleep 10;

        setup_node_modules
        setup_with_redis
        install_plugins
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
        sleep 10;

        setup_node_modules
        setup_with_mongo
        install_plugins
        install_themes

        exit 0
    elif [ "$1" = "pre-setup" ]; then
        sleep 10;

        apt-get update
        apt-get install -y mongodb-clients

        mongo "mongo-setup:$NODEBB_MONGO_PORT/$NODEBB_MONGO_DB" --eval "db.createUser({user: '$NODEBB_MONGO_USER', pwd: '$NODEBB_MONGO_PASSWORD', roles: [{role: 'readWrite', db: '$NODEBB_MONGO_DB'}]});"
        exit 0
    fi
else
    echo "Unsupported database $NODEBB_DATABASE"
    exit 1
fi

if [ "$1" = "start" ]; then
    cd /nodebb/core
    exec sudo -u www-data node app.js
    exit 0
fi

echo "Command $1 not found"
exit 1