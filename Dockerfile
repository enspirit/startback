###
### BASE TARGET
###

ARG MRI_VERSION
FROM ruby:${MRI_VERSION} as base

LABEL maintainer=blambeau@enspirit.be

ENV LANG C.UTF-8
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update -qq \
 && apt-get install -qq --no-install-recommends \
    curl \
    vim \
    libsasl2-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add user
RUN addgroup --gid 1000 --system app \
 && adduser --uid 1000 --system --gid 1000 app \
 && mkdir -p /home/app \
 && chown app:app -R /home/app

# Set correct environment variables and workdir
ENV HOME /home/app
WORKDIR /home/app

COPY . /tmp/startback
RUN cd /tmp/startback && \
    mkdir -p /tmp/startback/pkg && \
    gem build -o pkg/startback-base.gem startback-base.gemspec && \
    gem install pkg/startback-base.gem && \
    rm -rf /tmp/startback

###
### API TARGET
###
FROM base as api

COPY . /tmp/startback
RUN cd /tmp/startback && \
    mkdir -p /tmp/startback/pkg && \
    gem build -o pkg/startback-api.gem startback-api.gemspec && \
    gem install pkg/startback-api.gem && \
    rm -rf /tmp/startback

USER app

CMD bundle exec puma -p 3000

###
### ENGINE TARGET
###
FROM base as engine

COPY . /tmp/startback
RUN cd /tmp/startback && \
    mkdir -p /tmp/startback/pkg && \
    gem build -o pkg/startback-engine.gem startback-engine.gemspec && \
    gem install pkg/startback-engine.gem && \
    rm -rf /tmp/startback

USER app

CMD bundle exec puma -t 1:1 -w 0 -p 3000 config.engine.ru

###
### WEB TARGET
###
FROM base as web

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq \
 && apt-get install -qq --no-install-recommends \
    nodejs \
    yarn \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /tmp/startback
RUN cd /tmp/startback && \
    mkdir -p /tmp/startback/pkg && \
    gem build -o pkg/startback-web.gem startback-web.gemspec && \
    gem install pkg/startback-web.gem && \
    rm -rf /tmp/startback

USER app

CMD bundle exec puma -p 3000
