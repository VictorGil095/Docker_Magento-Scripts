#!/bin/sh
set -e

apk add --no-cache openjdk11-jre-headless
apk add --no-cache bash

VERSION="7.10.0"
DOWNLOAD_URL="https://artifacts.elastic.co/downloads/elasticsearch"
ES="${DOWNLOAD_URL}/elasticsearch-oss-${VERSION}-no-jdk-linux-x86_64.tar.gz"

apk add --no-cache -t .build-deps wget \
  && set -ex \
  && cd /tmp \
  && wget --progress=bar:force -O elasticsearch.tar.gz "${ES}"; \
  tar -xf elasticsearch.tar.gz \
  && mv elasticsearch-${VERSION} /usr/share/elasticsearch \
  && adduser -D -h /usr/share/elasticsearch elasticsearch \
  && for path in \
  /usr/share/elasticsearch/data \
  /usr/share/elasticsearch/logs \
  /usr/share/elasticsearch/config \
  /usr/share/elasticsearch/config/scripts \
  /usr/share/elasticsearch/tmp \
  /usr/share/elasticsearch/plugins \
  ; do \
  mkdir -p "$path"; \
  chown -R elasticsearch:elasticsearch "$path"; \
  done \
  && rm -rf /tmp/* /usr/share/elasticsearch/jdk \
  && apk del --purge .build-deps

rm -rf /usr/share/elasticsearch/modules/x-pack-ml/platform/linux-x86_64

