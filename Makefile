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

# Specify which ruby version is used as base
DEFAULT_MRI_VERSION := 3.4
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

.build/buildx.builder:
	mkdir -p .build
	docker buildx create --use --name startback
	touch .build/buildx.builder

ifeq (${VERSION},latest)
.build/%/Dockerfile.built: Dockerfile .build/
	@docker buildx build -f $< ./\
		--build-arg MRI_VERSION=${MRI_VERSION} \
		--push \
		--platform ${PLATFORMS} \
		--target $* \
		-t $(DOCKER_REGISTRY)/startback:$* \
		-t $(DOCKER_REGISTRY)/startback:$*-ruby${MRI_VERSION}
else
.build/%/Dockerfile.built: Dockerfile
	@docker buildx build -f $< ./ \
		--push \
		--build-arg MRI_VERSION=${MRI_VERSION} \
		--platform ${PLATFORMS} \
		--target $* \
		-t $(DOCKER_REGISTRY)/startback:$* \
		-t $(DOCKER_REGISTRY)/startback:$*-${TINY} \
		-t $(DOCKER_REGISTRY)/startback:$*-${MINOR} \
		-t $(DOCKER_REGISTRY)/startback:$*-ruby${MRI_VERSION} \
		-t $(DOCKER_REGISTRY)/startback:$*-$(TINY)-ruby${MRI_VERSION} \
		-t $(DOCKER_REGISTRY)/startback:$*-$(MINOR)-ruby${MRI_VERSION}
endif
