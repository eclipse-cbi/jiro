#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
DOCKER_REPO=`.jsonnet/jsonnet globals.jsonnet | jq -r .docker.repository`

INSTANCES=$(patsubst instances/%,%,$(wildcard instances/*))
IMAGE_INSTANCES=$(patsubst %,image_%,$(INSTANCES))
K8S_INSTANCES=$(patsubst %,k8s_%,$(INSTANCES))
PUSH_INSTANCES=$(patsubst %,push_%,$(INSTANCES))
DEPLOY_INSTANCES=$(patsubst %,deploy_%,$(INSTANCES))
CLEAN_INSTANCES=$(patsubst %,clean_%,$(INSTANCES))
DELETE_INSTANCES=$(patsubst %,delete_%,$(INSTANCES))
GENCONFIG_INSTANCES=$(patsubst %,genconfig_%,$(INSTANCES))
DOCKERTOOLS_PATH=.dockertools

.PHONY: all clean all_images push_all_images k8s_all_instances deploy_all_instances clean_all_instances tests jenkins-master-base push_jenkins-master-base $(IMAGE_INSTANCES) $(K8S_INSTANCES) $(PUSH_INSTANCES) $(DEPLOY_INSTANCES) $(CLEAN_INSTANCES) $(DELETE_INSTANCES) $(GENCONFIG_INSTANCES) error_resources error_pages deploy_error_pages clone_jsonnet dockertools

dockertools:
	if [[ -d "${DOCKERTOOLS_PATH}" ]]; then \
	  git -C "${DOCKERTOOLS_PATH}" fetch -f --no-tags --progress --depth 1 https://github.com/eclipse-cbi/dockertools.git +refs/heads/master:refs/remotes/origin/master; \
	  git -C "${DOCKERTOOLS_PATH}" checkout -f "$$(git -C "${DOCKERTOOLS_PATH}" rev-parse refs/remotes/origin/master)"; \
	else \
	  git init "${DOCKERTOOLS_PATH}"; \
	  git -C "${DOCKERTOOLS_PATH}" fetch --no-tags --progress --depth 1 https://github.com/eclipse-cbi/dockertools.git +refs/heads/master:refs/remotes/origin/master; \
	  git -C "${DOCKERTOOLS_PATH}" config remote.origin.url https://github.com/eclipse-cbi/dockertools.git; \
	  git -C "${DOCKERTOOLS_PATH}" config --add remote.origin.fetch +refs/heads/master:refs/remotes/origin/master; \
	  git -C "${DOCKERTOOLS_PATH}" config core.sparsecheckout true; \
	  git -C "${DOCKERTOOLS_PATH}" config advice.detachedHead false; \
	  git -C "${DOCKERTOOLS_PATH}" checkout -f "$$(git -C "${DOCKERTOOLS_PATH}" rev-parse refs/remotes/origin/master)"; \
	fi

error_resources: dockertools
	.dockertools/dockerw build "eclipsecbijenkins/error_resources" "latest" "./error_pages/resources.Dockerfile"
	.dockertools/dockerw push "eclipsecbijenkins/error_resources" "latest"

error_pages: error_resources
	.dockertools/dockerw build "eclipsecbijenkins/maintenance_page" "latest" "./error_pages/maintenance.Dockerfile"
	.dockertools/dockerw push "eclipsecbijenkins/maintenance_page" "latest"

deploy_error_pages: error_pages
	oc apply -f ./error_pages/resources.pod.yml
	oc apply -f ./error_pages/maintenance.pod.yml

jenkins-master-base: dockertools
	find jenkins-master-base -mindepth 1 -maxdepth 1 -type d -exec jenkins-master-base/build.sh {} \;

push_jenkins-master-base: jenkins-master-base
	find jenkins-master-base -mindepth 1 -maxdepth 1 -type d -exec jenkins-master-base/push.sh {} \;

$(GENCONFIG_INSTANCES): genconfig_% : .jsonnet/jsonnet $(wildcard templates/**/*) instances/%/jiro.jsonnet instances/%/config.jsonnet
	./build/gen-config.sh instances/$(patsubst genconfig_%,%,$@)

$(IMAGE_INSTANCES): image_% : push_jenkins-master-base genconfig_%
	./build/build-image.sh instances/$(patsubst image_%,%,$@)

all_images: $(IMAGE_INSTANCES)

$(K8S_INSTANCES): k8s_% : image_%
	./build/gen-k8s.sh instances/$(patsubst k8s_%,%,$@)

k8s_all_instances: $(K8S_INSTANCES)

$(DEPLOY_INSTANCES): deploy_% : k8s_%
	./build/k8s-deploy.sh instances/$(patsubst deploy_%,%,$@)

deploy_all_instances: $(DEPLOY_INSTANCES)

$(CLEAN_INSTANCES): clean_% : genconfig_%
	./build/clean-instance.sh instances/$(patsubst clean_%,%,$@)

clean_all_instances: $(CLEAN_INSTANCES)
	.dockertools/dockerw rmi_all ${DOCKER_REPO}/jenkins-master-base

$(DELETE_INSTANCES):
	./build/k8s-delete.sh instances/$(patsubst delete_%,%,$@)

.jsonnet: 
	git clone https://github.com/google/jsonnet.git .jsonnet || git -C .jsonnet fetch
	git -C .jsonnet reset --hard master && git -C .jsonnet clean -f -d

.jsonnet/jsonnet: .jsonnet
	make -C .jsonnet

tests: jenkins-master-base
	./tests/run.sh

all: deploy_all_instances

clean: clean_all_instances
	.dockertools/dockerw clean
