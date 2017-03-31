FROM redis

RUN crontab -l > mycron \
    && echo '* * * * * redis-cli -h redis -a "$NODEBB_REDIS_PASSWORD" save' \
    && crontab mycron \
    && rm mycron
