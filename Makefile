#*******************************************************************************
# Copyright (c) 2018 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************
DOCKER_REPO=`cat repositoryName`

INSTANCES=$(patsubst instances/%,%,$(wildcard instances/*))
IMAGE_INSTANCES=$(patsubst %,image_%,$(INSTANCES))
K8S_INSTANCES=$(patsubst %,k8s_%,$(INSTANCES))
PUSH_INSTANCES=$(patsubst %,push_%,$(INSTANCES))
DEPLOY_INSTANCES=$(patsubst %,deploy_%,$(INSTANCES))
CLEAN_INSTANCES=$(patsubst %,clean_%,$(INSTANCES))
DELETE_INSTANCES=$(patsubst %,delete_%,$(INSTANCES))
GENCONFIG_INSTANCES=$(patsubst %,genconfig_%,$(INSTANCES))

.PHONY: all clean all_images push_all_images k8s_all_instances deploy_all_instances clean_all_instances tests openshift-java push_openshift-java jenkins-master-base push_jenkins-master-base jenkins-agent push_jenkins-agent $(IMAGE_INSTANCES) $(K8S_INSTANCES) $(PUSH_INSTANCES) $(DEPLOY_INSTANCES) $(CLEAN_INSTANCES) $(DELETE_INSTANCES) $(GENCONFIG_INSTANCES) error_resources error_pages deploy_error_pages clone_jsonnet

error_resources:
	./build/dockerw build "eclipsecbijenkins/error_resources" "latest" "./error_pages/resources.Dockerfile"
	./build/dockerw push "eclipsecbijenkins/error_resources" "latest"

error_pages: error_resources
	./build/dockerw build "eclipsecbijenkins/maintenance_page" "latest" "./error_pages/maintenance.Dockerfile"
	./build/dockerw push "eclipsecbijenkins/maintenance_page" "latest"

deploy_error_pages: error_pages
	oc apply -f ./error_pages/resources.pod.yml
	oc apply -f ./error_pages/maintenance.pod.yml

openshift-java:
	./build/dockerw build_all ${DOCKER_REPO} $@

push_openshift-java: openshift-java
	./build/dockerw push_all ${DOCKER_REPO} $<

jenkins-agent: openshift-java
	find jenkins-agent-images/jenkins-agent -mindepth 1 -maxdepth 1 -type d -exec jenkins-agent-images/jenkins-agent/build.sh {} \;

push_jenkins-agent: jenkins-agent
	./build/dockerw push_all ${DOCKER_REPO} jenkins-agent-images/$<

jenkins-master-base: openshift-java
	find jenkins-master-base -mindepth 1 -maxdepth 1 -type d -exec jenkins-master-base/build.sh {} \;

push_jenkins-master-base: jenkins-master-base
	./build/dockerw push_all ${DOCKER_REPO} $<

# requires push_jenkins-agent to get jenkins-agent sha
$(GENCONFIG_INSTANCES): genconfig_% : .jsonnet/jsonnet templates/default.libsonnet templates/permissions.libsonnet instances/%/config.jsonnet push_jenkins-agent
	./build/gen-config.sh instances/$(patsubst genconfig_%,%,$@)

$(IMAGE_INSTANCES): image_% : jenkins-master-base genconfig_%
	./build/build-image.sh instances/$(patsubst image_%,%,$@)

all_images: $(IMAGE_INSTANCES)

$(PUSH_INSTANCES): push_% : image_%
	./build/push-image.sh instances/$(patsubst push_%,%,$@)

push_all_images: push_openshift-java push_jenkins-master-base push_jenkins-agent $(PUSH_INSTANCES)

$(K8S_INSTANCES): k8s_% : push_%
	./build/gen-k8s.sh instances/$(patsubst k8s_%,%,$@)

k8s_all_instances: $(K8S_INSTANCES)

$(DEPLOY_INSTANCES): deploy_% : k8s_%
	./build/k8s-deploy.sh instances/$(patsubst deploy_%,%,$@)

deploy_all_instances: $(DEPLOY_INSTANCES)

$(CLEAN_INSTANCES): clean_% : genconfig_%
	./build/clean-instance.sh instances/$(patsubst clean_%,%,$@)

clean_all_instances: $(CLEAN_INSTANCES)
	./build/dockerw rmi_all ${DOCKER_REPO}/jenkins-master-base
	./build/dockerw rmi_all ${DOCKER_REPO}/openshift-java

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
	./build/dockerw clean
