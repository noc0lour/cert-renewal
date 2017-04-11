# noc0lour/gnuradio-buildbot-worker:controller

# please follow docker best practices
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/
#
# Provides a base alpine 3.4 image with latest buildbot master installed
# Alpine base build is ~130MB vs ~500MB for the ubuntu build

# Note that the UI and worker packages are the latest version published on pypi
# This is to avoid pulling node inside this container

FROM        alpine:3.5
MAINTAINER  Andrej Rode <mail@andrejro.de>

# Last build date - this can be updated whenever there are security updates so
# that everything is rebuilt
ENV         security_updates_as_of 2017-02-08

RUN \
    echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
    echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
    apk add --no-cache \
        build-base \
        dumb-init@edge \
        curl \
        gcc \
        grep \
        libffi-dev \
        musl-dev \
        openssl \
        openssl-dev \
        py-pip \
        python \
        python-dev \
        bash \
        sed

COPY hooks/cloudflare/requirements-python-2.txt ./requirements-python-2.txt

RUN pip install -r requirements-python-2.txt && \
    rm -rf /root/.cache

RUN adduser -D -u 1000 -s /bin/bash -h /work user && chown -R user /work

USER user

WORKDIR /work

COPY dehydrated dehydrated
COPY hooks hooks

CMD ["dumb-init", "./dehydrated/dehydrated", "-c"]
