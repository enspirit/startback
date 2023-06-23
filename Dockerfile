###
### MAIN TARGET
###
ARG MRI_VERSION
FROM ruby:${MRI_VERSION} as api

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

USER app

CMD bundle exec puma -p 3000

###
### WEB TARGET
###
FROM api as web

USER root

RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq \
 && apt-get install -qq --no-install-recommends \
    nodejs \
    yarn \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER app

CMD bundle exec puma -p 3000
