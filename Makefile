IMAGES := base api web engine

################################################################################
#### Config variables
###

# Load them from an optional .env file
-include .env

# Specify which docker tag is to be used
DOCKER_TAG := $(or ${DOCKER_TAG},${DOCKER_TAG},latest)
DOCKER_REGISTRY := $(or ${DOCKER_REGISTRY},${DOCKER_REGISTRY},docker.io)

K8S_NAMESPACE := $(or ${K8S_NAMESPACE},${K8S_NAMESPACE},stg-klaro)

### global

clean:
	rm -rf Dockerfile.*.log Dockerfile.*.built

images: $(addsuffix .image,$(IMAGES))
push-images: $(addsuffix .push,$(IMAGES))

### specific

define make-goal
Dockerfile.$1.built: Dockerfile.$1
	docker build -t enspirit/startback-$1-2.7 -f Dockerfile.$1 .  | tee Dockerfile.$1.log
	touch Dockerfile.$1.built

$1.image: Dockerfile.$1.built

Dockerfile.$1.pushed: Dockerfile.$1.built
	docker tag enspirit/startback-$1-2.7 $(DOCKER_REGISTRY)/enspirit/startback-$1-2.7:$(DOCKER_TAG)
	docker push $(DOCKER_REGISTRY)/enspirit/startback-$1-2.7:$(DOCKER_TAG) | tee -a Dockerfile.$1.log
	touch Dockerfile.$1.pushed

$1.push: Dockerfile.$1.pushed
endef
$(foreach image,$(IMAGES),$(eval $(call make-goal,$(image))))
