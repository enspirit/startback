SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

IMAGES := base api web engine tests
PUSH_IMAGES := base api web engine

CONTRIBS = startback-jobs

################################################################################
#### Config variables
###

# Load them from an optional .env file
-include .env

# Specify which ruby version is used as base
MRI_VERSION := $(or ${MRI_VERSION},${MRI_VERSION},2.7)

# Specify which docker tag is to be used
VERSION := $(or ${VERSION},${VERSION},latest)
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io/enspirit)

TINY = ${VERSION}
MINOR = $(shell echo '${TINY}' | cut -f'1-2' -d'.')
# not used until 1.0
# MAJOR = $(shell echo '${MINOR}' | cut -f'1-2' -d'.')

### global

clean: $(addsuffix .clean,$(CONTRIBS))
	rm -rf Gemfile.lock Dockerfile.*.log Dockerfile.*.built pkg/* example/Gemfile.lock

Gemfile.lock: Gemfile *.gemspec lib/**/*
	bundle install --path vendor/bundle

example/Gemfile.lock: Gemfile.lock example/Gemfile
	cd example && bundle install --path vendor/bundle

bundle: Gemfile.lock example/Gemfile.lock $(addprefix contrib/,$(addsuffix /Gemfile.lock,$(CONTRIBS)))

test: Gemfile.lock example/Gemfile.lock $(addprefix contrib/,$(addsuffix /Gemfile.lock,$(CONTRIBS)))
	bundle exec rake test

ci: Dockerfile.tests.built
	docker run enspirit/startback:tests

images: $(addsuffix .image,$(IMAGES))
push-images: $(addsuffix .push-image,$(PUSH_IMAGES))

gem: $(addsuffix .gem,$(PUSH_IMAGES)) $(addsuffix .gem,$(CONTRIBS))
push-gem: $(addsuffix .push-gem,$(PUSH_IMAGES))

### contribs

define make-contrib-targets

$1.clean:
	rm contrib/$1/Gemfile.lock contrib/$1/pkg/*

contrib/$1/Gemfile.lock: contrib/$1/Gemfile contrib/$1/$1.gemspec
	cd contrib/$1
	bundle install

contrib/$1/pkg/$1.${VERSION}.gem: contrib/$1/$1.gemspec contrib/$1/lib/**/*
	docker run --rm -t -v ${PWD}:/app -w /app ruby bash -c 'cd contrib/$1 && mkdir -p pkg && gem build -o pkg/$1.${VERSION}.gem $1.gemspec'

$1.gem: contrib/$1/pkg/$1.${VERSION}.gem

$1.push-gem: contrib/$1/pkg/$1.${VERSION}.gem
	docker run --rm -t -v ${PWD}:/app -w /app -e GEM_HOST_API_KEY=${GEM_HOST_API_KEY} ruby bash -c 'cd contrib/$1 && gem push pkg/$1.${VERSION}.gem'

endef
$(foreach contrib,$(CONTRIBS),$(eval $(call make-contrib-targets,$(contrib))))

### specific

define make-goal
Dockerfile.$1.built: Dockerfile.$1 startback-$1.gemspec
	docker build -t enspirit/startback:$1 -f Dockerfile.$1 --build-arg MRI_VERSION=${MRI_VERSION} . | tee Dockerfile.$1.log
	touch Dockerfile.$1.built

$1.image: Dockerfile.$1.built

Dockerfile.$1.pushed: Dockerfile.$1.built
	# Without ruby suffix
	docker push enspirit/startback:$1 | tee -a Dockerfile.$1.log
	docker tag enspirit/startback:$1 enspirit/startback:$1-${TINY}
	docker push enspirit/startback:$1-$(TINY) | tee -a Dockerfile.$1.log
	docker tag enspirit/startback:$1 enspirit/startback:$1-${MINOR}
	docker push enspirit/startback:$1-$(MINOR) | tee -a Dockerfile.$1.log
	# With ruby suffix
	docker tag enspirit/startback:$1 enspirit/startback:$1-ruby${MRI_VERSION}
	docker push enspirit/startback:$1-ruby${MRI_VERSION}
	docker tag enspirit/startback:$1 enspirit/startback:$1-${TINY}-ruby${MRI_VERSION}
	docker push enspirit/startback:$1-$(TINY)-ruby${MRI_VERSION} | tee -a Dockerfile.$1.log
	docker tag enspirit/startback:$1 enspirit/startback:$1-${MINOR}-ruby${MRI_VERSION}
	docker push enspirit/startback:$1-$(MINOR)-ruby${MRI_VERSION} | tee -a Dockerfile.$1.log
	# not used until 1.0
	# docker tag enspirit/startback:$1-ruby${MRI_VERSION} enspirit/startback:$1-${MAJOR}-ruby${MRI_VERSION}
	# docker push enspirit/startback:$1-$(MAJOR)-ruby${MRI_VERSION} | tee -a Dockerfile.$1.log
	touch Dockerfile.$1.pushed

$1.push-image: Dockerfile.$1.pushed

pkg/startback-$1.${VERSION}.gem: startback-$1.gemspec startback.gemspec.rb lib/**/*
	docker run --rm -t -v ${PWD}/:/app -w /app ruby bash -c 'gem build -o pkg/startback-$1.${VERSION}.gem startback-$1.gemspec'

$1.gem: pkg/startback-$1.${VERSION}.gem

$1.push-gem: pkg/startback-$1.${VERSION}.gem
	docker run --rm -t -v ${PWD}/:/app -w /app -e GEM_HOST_API_KEY=${GEM_HOST_API_KEY} ruby bash -c 'gem push pkg/startback-$1.${VERSION}.gem'
endef
$(foreach image,$(IMAGES),$(eval $(call make-goal,$(image))))

Dockerfile.tests.built: Dockerfile.tests $(shell find lib spec example -type f | grep -v "Gemfile.*" | grep -v vendor)
Dockerfile.api.built: Dockerfile.base.built
Dockerfile.web.built: Dockerfile.base.built
Dockerfile.engine.built: Dockerfile.base.built
