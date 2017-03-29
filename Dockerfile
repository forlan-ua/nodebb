FROM node:latest


RUN \
    apt-get update \

    # Install packages
    && apt-get install -y imagemagick build-essential wget curl \

    # Cleanup
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*


WORKDIR /nodebb
VOLUME /nodebb
EXPOSE 4567


CMD [ "node", "app.js" ]