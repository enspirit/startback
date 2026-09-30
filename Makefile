SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

##
## Debug
##
print-% : ; $(info $* is a $(flavor $*) variable set to [$($*)]) @true

###

GEMSPECS = $(shell find . -maxdepth 3 -name \*.gemspec | sed 's/^.\///g')
GEMS = $(GEMSPECS:%.gemspec=%.gem)
PROJECTS = $(shell find . -maxdepth 3 -name Rakefile -exec dirname {} \;)

### GEM HANDLING

# Build a .gem from a .gemspec
%.gem: %.gemspec
	@echo ===================================================================
	@echo "Building gem $@"
	@echo ===================================================================
	@cd $(dir $@)
	@gem build -o $(notdir $@) $(notdir $<)

# Build all gems
gems: $(GEMS)

# Push a built gem
%.gem.push: %.gem
	@echo ===================================================================
	@echo "Pushing gem $<"
	@echo ===================================================================
	@gem push $<

# Push all gems
gems.push: $(addsuffix .push, $(GEMS))

# Remove built gems
clean:
	@rm -rf *.gem */**/*.gem .build

### BUNDLES

bundle: $(addsuffix .bundle,$(PROJECTS))

define bundle-targets
$1.bundle:
	@echo ===================================================================
	@echo "Bundling $1"
	@echo ===================================================================
	cd $1 && bundle install
endef
$(foreach project,$(PROJECTS),$(eval $(call bundle-targets,$(project))))

#####
### ADDITIONAL DEPS / TARGETS
#####

-include contrib/*/makefile.mk

#####
### TESTS
#####

tests: gems $(addsuffix .test,$(PROJECTS))

### BACKING SERVICES

# The Bunny bus specs need a real broker. Without one they skip, so this is
# optional locally; CI sets STARTBACK_SPEC_REQUIRE_BUNNY to make the same
# situation a failure there.
rabbitmq.up:
	docker compose up -d rabbitmq
	@echo "Waiting for RabbitMQ to answer..."
	@for i in $$(seq 1 60); do
	  if docker compose exec -T rabbitmq rabbitmq-diagnostics -q ping >/dev/null 2>&1; then
	    echo "RabbitMQ is up. Export the url the specs look for:"
	    echo "  export STARTBACK_BUS_BUNNY_ASYNC_URL=amqp://guest:guest@localhost:$${STARTBACK_RABBITMQ_PORT:-5672}"
	    exit 0
	  fi
	  sleep 1
	done
	echo "RabbitMQ did not come up in time" >&2
	exit 1

rabbitmq.down:
	docker compose down -v

define test-targets
$1.test::
	@echo ===================================================================
	@echo "Executing $1 tests"
	@echo ===================================================================
	cd $1 && bundle exec rake test
endef
$(foreach project,$(PROJECTS),$(eval $(call test-targets,$(project))))

#####
### DOCKER
#####

# Specify which ruby version is used as base. Images are released for every
# version in RELEASE_MRI_VERSIONS, one CI job each, and DEFAULT_MRI_VERSION is
# the one a plain `make images` builds.
DEFAULT_MRI_VERSION := 3.4
RELEASE_MRI_VERSIONS := 3.4 4.0
MRI_VERSION := $(or ${MRI_VERSION},${MRI_VERSION},$(DEFAULT_MRI_VERSION))

VERSION := $(or ${VERSION},${VERSION},latest)
TINY = ${VERSION}
MINOR = $(shell echo '${TINY}' | cut -f'1-2' -d'.')
# not used until 1.0
# MAJOR = $(shell echo '${MINOR}' | cut -f'1-2' -d'.')

DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io/enspirit)
PLATFORMS := linux/amd64,linux/arm64/v8

TARGETS := api web
IMAGES = $(TARGETS:%=.build/%/Dockerfile.built)

images: .build/buildx.builder ${IMAGES}

# Build and push every ruby version of the release matrix, which is what the
# release-images workflow does with one job per version. Sequential here,
# so mostly useful to check a Dockerfile change against all of them.
images.all:
	for mri in ${RELEASE_MRI_VERSIONS}; do
	  ${MAKE} images MRI_VERSION=$$mri
	done

.build/buildx.builder:
	mkdir -p .build
	docker buildx create --use --name startback
	touch .build/buildx.builder

# Tags naming the ruby version they were built with. Every version of the
# release matrix pushes those, so each one stays reachable on its own.
TAGS = $*-ruby${MRI_VERSION}
ifneq (${VERSION},latest)
TAGS += $*-${TINY}-ruby${MRI_VERSION} $*-${MINOR}-ruby${MRI_VERSION}
endif

# Tags naming no ruby version. Those are reserved for DEFAULT_MRI_VERSION:
# since several versions are released in parallel, whoever pushed last would
# otherwise decide what `startback:api` means. Applications that want another
# one ask for it by name, through the tags above.
ifeq (${MRI_VERSION},${DEFAULT_MRI_VERSION})
TAGS += $*
ifneq (${VERSION},latest)
TAGS += $*-${TINY} $*-${MINOR}
endif
endif

.build/%/Dockerfile.built: Dockerfile
	@docker buildx build -f $< ./ \
		--push \
		--build-arg MRI_VERSION=${MRI_VERSION} \
		--platform ${PLATFORMS} \
		--target $* \
		$(addprefix -t $(DOCKER_REGISTRY)/startback:,${TAGS})
