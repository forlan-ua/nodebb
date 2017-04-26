FROM node:latest


RUN \
    apt-get update \

    # Install packages
    && apt-get install -y sudo git imagemagick build-essential wget curl unzip \

    # Cleanup
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*


RUN mkdir /nodebb && mkdir -p /var/www && chown www-data:www-data /var/www
VOLUME /nodebb/core
VOLUME /nodebb/plugins
VOLUME /nodebb/themes


EXPOSE 4567


WORKDIR /nodebb
COPY run.sh /nodebb/run.sh
RUN chmod +x /nodebb/run.sh
ENTRYPOINT ["/nodebb/run.sh"]