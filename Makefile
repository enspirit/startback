IMAGES := base api web engine tests
PUSH_IMAGES := base api web engine

################################################################################
#### Config variables
###

# Load them from an optional .env file
-include .env

# Specify which docker tag is to be used
VERSION := $(or ${VERSION},${VERSION},latest)
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},q8s.dev/enspirit)

K8S_NAMESPACE := $(or ${K8S_NAMESPACE},${K8S_NAMESPACE},stg-klaro)

TINY = ${VERSION}
MINOR = $(shell echo '${TINY}' | cut -f'1-2' -d'.')
# not used until 1.0
# MAJOR = $(shell echo '${MINOR}' | cut -f'1-2' -d'.')

### global

clean:
	rm -rf Gemfile.lock Dockerfile.*.log Dockerfile.*.built pkg/* example/Gemfile.lock

Gemfile.lock: Gemfile *.gemspec lib/**/*
	bundle install --path vendor/bundle

example/Gemfile.lock: Gemfile.lock example/Gemfile
	cd example && bundle install --path vendor/bundle

bundle: Gemfile.lock example/Gemfile.lock

test: Gemfile.lock example/Gemfile.lock
	bundle exec rake test

ci: Dockerfile.tests.built
	docker run startback/tests-2.7

images: $(addsuffix .image,$(IMAGES))
push-images: $(addsuffix .push-image,$(PUSH_IMAGES))

gem: $(addsuffix .gem,$(PUSH_IMAGES))
push-gem: $(addsuffix .push-gem,$(PUSH_IMAGES))

### specific

define make-goal
Dockerfile.$1.built: Dockerfile.$1 startback-$1.gemspec
	docker build -t startback/$1-2.7 -f Dockerfile.$1 .  | tee Dockerfile.$1.log
	touch Dockerfile.$1.built

$1.image: Dockerfile.$1.built

Dockerfile.$1.pushed: Dockerfile.$1.built
	docker tag startback/$1-2.7 $(DOCKER_REGISTRY)/startback/$1-2.7:${TINY}
	docker push $(DOCKER_REGISTRY)/startback/$1-2.7:$(TINY) | tee -a Dockerfile.$1.log
	docker tag startback/$1-2.7 $(DOCKER_REGISTRY)/startback/$1-2.7:${MINOR}
	docker push $(DOCKER_REGISTRY)/startback/$1-2.7:$(MINOR) | tee -a Dockerfile.$1.log
	# not used until 1.0
	# docker tag startback/$1-2.7 $(DOCKER_REGISTRY)/startback/$1-2.7:${MAJOR}
	# docker push $(DOCKER_REGISTRY)/startback/$1-2.7:$(MAJOR) | tee -a Dockerfile.$1.log
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
