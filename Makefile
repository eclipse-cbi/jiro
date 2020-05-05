#*******************************************************************************
# Copyright (c) 2018-2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
SHELL=/usr/bin/env bash

INSTANCES=$(patsubst instances/%,%,$(wildcard instances/*))
IMAGE_INSTANCES=$(patsubst %,image_%,$(INSTANCES))
K8S_INSTANCES=$(patsubst %,k8s_%,$(INSTANCES))
PUSH_INSTANCES=$(patsubst %,push_%,$(INSTANCES))
DEPLOY_INSTANCES=$(patsubst %,deploy_%,$(INSTANCES))
CLEAN_INSTANCES=$(patsubst %,clean_%,$(INSTANCES))
DELETE_INSTANCES=$(patsubst %,delete_%,$(INSTANCES))
GENCONFIG_INSTANCES=$(patsubst %,genconfig_%,$(INSTANCES))
DOCKERTOOLS_PATH=.dockertools

.PHONY: all clean all_images push_all_images k8s_all_instances deploy_all_instances clean_all_instances tests $(IMAGE_INSTANCES) $(K8S_INSTANCES) $(PUSH_INSTANCES) $(DEPLOY_INSTANCES) $(CLEAN_INSTANCES) $(DELETE_INSTANCES) $(GENCONFIG_INSTANCES) error_resources error_pages deploy_error_pages dockertools

.bashtools:
	bash -c "$$(curl -fsSL https://raw.githubusercontent.com/completeworks/bashtools/master/install.sh)"

.dockertools: .bashtools
	.bashtools/gitw sparsecheckout https://github.com/eclipse-cbi/dockertools.git $@

error_resources: .dockertools
	.dockertools/dockerw build "eclipsecbijenkins/error_resources" "latest" "./error_pages/resources.Dockerfile"
	.dockertools/dockerw push "eclipsecbijenkins/error_resources" "latest"

error_pages: error_resources
	.dockertools/dockerw build "eclipsecbijenkins/maintenance_page" "latest" "./error_pages/maintenance.Dockerfile"
	.dockertools/dockerw push "eclipsecbijenkins/maintenance_page" "latest"

deploy_error_pages: error_pages
	oc apply -f ./error_pages/resources.pod.yml
	oc apply -f ./error_pages/maintenance.pod.yml

# Required for 'optional' jiro_phase2.jsonnet
.SECONDEXPANSION:
$(GENCONFIG_INSTANCES): genconfig_% : .dockertools $(wildcard templates/**/*) instances/%/jiro.jsonnet $$(instances/%/jiro_phase2.jsonnet) instances/%/config.jsonnet
	./build/gen-config.sh instances/$(patsubst genconfig_%,%,$@)

$(IMAGE_INSTANCES): image_% : genconfig_%
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

$(DELETE_INSTANCES):
	./build/k8s-delete.sh instances/$(patsubst delete_%,%,$@)

tests: jenkins-master-base
	./tests/run.sh

all: deploy_all_instances

clean: clean_all_instances
	rm -rf .bashtools .dockertools
	.dockertools/dockerw clean
