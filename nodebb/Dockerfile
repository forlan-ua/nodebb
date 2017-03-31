FROM node:latest


RUN \
    apt-get update \

    # Install packages
    && apt-get install -y git imagemagick build-essential wget curl \

    # Cleanup
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*


RUN mkdir /nodebb
VOLUME /nodebb/core
VOLUME /nodebb/plugins
VOLUME /nodebb/themes


EXPOSE 4567


WORKDIR /nodebb
COPY run.sh /nodebb/run.sh
CMD [ "bash", "run.sh" ]