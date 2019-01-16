export PATH := bin:$(PATH)
TEMPLATE_VARIABLE_PREFIX := "JENKINS_"
SHELL := $$SHELL

DOCKER_REPO=`cat repositoryName`

INSTANCES=$(patsubst instances/%,%,$(wildcard instances/*))
IMAGE_INSTANCES=$(patsubst %,image_%,$(INSTANCES))
K8S_INSTANCES=$(patsubst %,k8s_%,$(INSTANCES))
PUSH_INSTANCES=$(patsubst %,push_%,$(INSTANCES))
DEPLOY_INSTANCES=$(patsubst %,deploy_%,$(INSTANCES))
CLEAN_INSTANCES=$(patsubst %,clean_%,$(INSTANCES))
DELETE_INSTANCES=$(patsubst %,delete_%,$(INSTANCES))
GENPROP_INSTANCES=$(patsubst %,genprop_%,$(INSTANCES))

.PHONY: all clean all_images push_all_images k8s_all_instances deploy_all_instances clean_all_instances tests openshift-java push_openshift-java jenkins-master-base push_jenkins-master-base $(IMAGE_INSTANCES) $(K8S_INSTANCES) $(PUSH_INSTANCES) $(DEPLOY_INSTANCES) $(CLEAN_INSTANCES) $(DELETE_INSTANCES) $(GENPROP_INSTANCES)

openshift-java:
	./dockerw build_all ${DOCKER_REPO} $@

push_openshift-java: openshift-java
	./dockerw push_all ${DOCKER_REPO} $<

jenkins-master-base: openshift-java
	find jenkins-master-base -mindepth 1 -maxdepth 1 -type d -exec jenkins-master-base/build.sh {} \;

push_jenkins-master-base: jenkins-master-base
	./dockerw push_all ${DOCKER_REPO} $<

$(GENPROP_INSTANCES): genprop_% : templates/default.shsource instances/%/config.properties
	mkdir -p instances/$(patsubst genprop_%,%,$@)/target
	./expand-template-vars.sh $? > instances/$(patsubst genprop_%,%,$@)/target/config.properties

$(IMAGE_INSTANCES): image_% : jenkins-master-base genprop_%
	./gen-jenkins.sh instances/$(patsubst image_%,%,$@)
	./gen-dockerfile.sh instances/$(patsubst image_%,%,$@)
	source instances/$(patsubst image_%,%,$@)/target/config.properties; \
		./dockerw build $${JENKINS_MASTER_IMAGE} $${JENKINS_MASTER_IMAGE_TAG} instances/$(patsubst image_%,%,$@)/target/Dockerfile; \
		if [[ $${JENKINS_MASTER_IMAGE_TAG} != "latest" ]]; then ./dockerw tag_alias $${JENKINS_MASTER_IMAGE} $${JENKINS_MASTER_IMAGE_TAG} latest; fi

all_images: $(IMAGE_INSTANCES)

$(PUSH_INSTANCES): push_% : image_%
	source instances/$(patsubst push_%,%,$@)/target/config.properties; \
		./dockerw push $${JENKINS_MASTER_IMAGE} $${JENKINS_MASTER_IMAGE_TAG}; \
		if [[ $${JENKINS_MASTER_IMAGE_TAG} != "latest" ]]; then ./dockerw push $${JENKINS_MASTER_IMAGE} latest; fi

push_all_images: push_openshift-java push_jenkins-master-base $(PUSH_INSTANCES)

$(K8S_INSTANCES): k8s_% : push_%
	./gen-k8s.sh instances/$(patsubst k8s_%,%,$@)

k8s_all_instances: $(K8S_INSTANCES)

$(DEPLOY_INSTANCES): deploy_% : k8s_%
	./k8s-deploy.sh instances/$(patsubst deploy_%,%,$@)

deploy_all_instances: $(DEPLOY_INSTANCES)

$(CLEAN_INSTANCES): clean_% : genprop_%
	source instances/$(patsubst clean_%,%,$@)/target/config.properties; \
		./dockerw rmi_all $${JENKINS_MASTER_IMAGE}; \
	rm -rf instances/$(patsubst clean_%,%,$@)/target

clean_all_instances: $(CLEAN_INSTANCES)
	./dockerw rmi_all ${DOCKER_REPO}/jenkins-master-base
	./dockerw rmi_all ${DOCKER_REPO}/openshift-java

$(DELETE_INSTANCES):
	./k8s-delete.sh instances/$(patsubst delete_%,%,$@)

tests: jenkins-master-base
	./tests/run.sh

all: deploy_all_instances

clean: clean_all_instances
	./dockerw clean
