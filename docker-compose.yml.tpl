version: '2'

services:
  mongo-setup:
    image: mongo
    volumes:
      - ./data/mongo:/data/db

  mongo:
    extends: mongo-setup
    command: --auth

  redis:
    image: redis
    command: --requirepass <REDISPASS>
    volumes:
      - ./data/redis:/data

  nodebb:
    build: .
    command: node /nodebb/app.js
    ports:
      - "<EXPOSEPORT>:4567"
    depends_on:
      - <DATABASE>
    links:
      - <DATABASE>
    volumes:
      - ./data/nodebb:/nodebb