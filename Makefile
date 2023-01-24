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

bundles: $(addsuffix .bundle,$(PROJECTS))

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

define test-targets
$1.test::
	@echo ===================================================================
	@echo "Executing $1 tests"
	@echo ===================================================================
	cd $1 && bundle exec rake test
endef
$(foreach project,$(PROJECTS),$(eval $(call test-targets,$(project))))

# the websocket contrib has also tests for the javascript code base
./contrib/startback-websocket.test:: ./contrib/startback-websocket/node_modules
	@echo ===================================================================
	@echo "Running javascript tests for ./contrib/startback-websocket"
	@echo ===================================================================
	@cd contrib/startback-websocket && npm run test

#####
### DOCKER
#####

# Specify which ruby version is used as base
DEFAULT_MRI_VERSION := 3.1
MRI_VERSION := $(or ${MRI_VERSION},${MRI_VERSION},$(DEFAULT_MRI_VERSION))

VERSION := $(or ${VERSION},${VERSION},latest)
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io/enspirit)

TINY = ${VERSION}
MINOR = $(shell echo '${TINY}' | cut -f'1-2' -d'.')
# not used until 1.0
# MAJOR = $(shell echo '${MINOR}' | cut -f'1-2' -d'.')

DOCKERFILES := $(wildcard Dockerfile.*)
DOCKER_IMAGES = $(DOCKERFILES:Dockerfile.%=.build/%/Dockerfile.built)
DOCKER_TAGGED = $(DOCKERFILES:Dockerfile.%=.build/%/Dockerfile.tagged)
DOCKER_PUSHES = $(DOCKERFILES:Dockerfile.%=.build/%/Dockerfile.pushed)

images: ${DOCKER_IMAGES}
images.tag: ${DOCKER_TAGGED}
images.push: ${DOCKER_PUSHES}

.build/%/Dockerfile.built: Dockerfile.%
	@docker build -t startback:$* -f $< ./ --build-arg MRI_VERSION=${MRI_VERSION}

.build/%/Dockerfile.tagged: .build/%/Dockerfile.built
	@echo ===================================================================
	@echo "Tagging all startback:$* images"
	@echo ===================================================================

	if [ "${MRI_VERSION}" == "${DEFAULT_MRI_VERSION}" ]; then \
		# without version \
		docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*; \
		# with tiny \
		docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(TINY); \
		# with minor \
		docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(MINOR); \
	fi

	# with ruby version
	docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-ruby${MRI_VERSION}
	docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(TINY)-ruby${MRI_VERSION}
	docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(MINOR)-ruby${MRI_VERSION}

.build/%/Dockerfile.pushed: .build/%/Dockerfile.built
	@echo ===================================================================
	@echo "Pushing all startback:$* images"
	@echo ===================================================================

	if [ "${MRI_VERSION}" == "${DEFAULT_MRI_VERSION}" ]; then \
		# without version \
		docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*; \
		docker push $(DOCKER_REGISTRY)/startback:$*; \
		# with tiny \
		docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(TINY); \
		docker push $(DOCKER_REGISTRY)/startback:$*-$(TINY); \
		# with minor \
		docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(MINOR); \
		docker push $(DOCKER_REGISTRY)/startback:$*-$(MINOR); \
	fi

	# with ruby version
	docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-ruby${MRI_VERSION}
	docker push $(DOCKER_REGISTRY)/startback:$*-ruby${MRI_VERSION}
	docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(TINY)-ruby${MRI_VERSION}
	docker push $(DOCKER_REGISTRY)/startback:$*-$(TINY)-ruby${MRI_VERSION}
	docker tag startback:$* $(DOCKER_REGISTRY)/startback:$*-$(MINOR)-ruby${MRI_VERSION}
	docker push $(DOCKER_REGISTRY)/startback:$*-$(MINOR)-ruby${MRI_VERSION}

.build/engine/Dockerfile.built: .build/base/Dockerfile.built
.build/web/Dockerfile.built: .build/base/Dockerfile.built
.build/api/Dockerfile.built: .build/base/Dockerfile.built
