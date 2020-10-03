# hadolint ignore=DL3007
FROM apache/nifi-registry:latest

ENV DOCKERIZE_VERSION v0.6.1

USER root

# hadolint ignore=DL3008
RUN apt-get -yqq install --no-install-recommends git

# Install dockerize for the templates
RUN curl -fSL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    -o dockerize.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize.tar.gz \
    && rm dockerize.tar.gz

COPY ./templates ../templates
COPY docker-entrypoint.sh ../scripts/
RUN chmod +x ../scripts/docker-entrypoint.sh

USER nifi

ENTRYPOINT ["../scripts/docker-entrypoint.sh"]