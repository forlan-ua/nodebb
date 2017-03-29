NodeBB
======

Docker environment for local usage

## Linux

### Install with MongoDB

```bash
NODEBB_MONGO_USER=nodebb \
NODEBB_MONGO_PASSWORD=asd123 \
NODEBB_MONGO_DB=nodebb \
NODEBB_EXPOSE_PORT=4567 \
./setup-mongo.sh
```

* **NODEBB_MONGO_USER**, **NODEBB_MONGO_PASSWORD** - required environment variables
* **NODEBB_MONGO_DB** - not required. _nodebb_ as default
* **NODEBB_EXPOSE_PORT** - not required. _4567_ as default

### Install with Redis

```bash
NODEBB_REDIS_PASSWORD=asd123 \
NODEBB_REDIS_DB=0 \
NODEBB_EXPOSE_PORT=4567 \
./setup-redis.sh
```

* **NODEBB_REDIS_PASSWORD** - required environment variables
* **NODEBB_REDIS_DB** - not required. _0_ as default
* **NODEBB_EXPOSE_PORT** - not required. _4567_ as default

Also you can add other setup arguments:

* _--url_ - URL used to access this NodeBB
* _--secret_ - NodeBB secret
* _--admin:username_ - Administrator username
* _--admin:email_ - Administrator email address
* _--admin:password_ - Administrator password
* _--admin:password:confirm_ - Administrator confirm password