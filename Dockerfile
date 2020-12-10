FROM ruby:2.7 as base

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

RUN addgroup --gid 1000 --system app \
 && adduser --uid 1000 --system --gid 1000 app \
 && mkdir -p /home/app \
 && chown app:app -R /home/app

ENV HOME /home/app
WORKDIR /home/app
USER app

COPY --chown=app:app . ./
RUN bundle install

## Gems
FROM base as gems

RUN gem build -o pkg/startback-base.gem startback-base.gemspec && \
   gem build -o pkg/startback-api.gem startback-api.gemspec && \
   gem build -o pkg/startback-engine.gem startback-engine.gemspec && \
   gem build -o pkg/startback-web.gem startback-web.gemspec

## Api
FROM base as api

COPY --from=gems /home/app/pkg/startback-api.gem /tmp/startback-api.gem

RUN gem install /tmp/startback-api.gem
CMD bundle exec puma -t 1:5 -w 1 --preload -p 80

## Engine
FROM base as engine

COPY --from=gems /home/app/pkg/startback-engine.gem /tmp/startback-engine.gem

RUN gem install /tmp/startback-engine.gem
CMD bundle exec ruby engine.rb

## Web
FROM base as web

USER root
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq \
 && apt-get install -qq --no-install-recommends \
    nodejs \
    yarn \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER app

COPY --from=gems /home/app/pkg/startback-web.gem /tmp/startback-web.gem

RUN gem install /tmp/startback-web.gem

CMD bundle exec puma -t 1:5 -w 1 --preload -p 80
