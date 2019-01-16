# Eclipse CBI - jiro

Jenkins infrastructure for projects hosted by the Eclipse Foundation

## Tasks

Build and deployment tasks are implemented as Make targets. Dependencies are properly specified, so you don't need to run all the following tasks, e.g., deploy will first build and push the imaegs, then generates the Kubernetes configuration files and finally deploy the instance on the cluster.

### Build the Jenkins docker image of a project

    $ make image_<project_full_name>

### Push a Jenkins image to DockerHub

    $ make push_<project_full_name>

### Generate Kubernetes (OpenShift) configuration files

    $ make k8s_<project_full_name>

### Deploy Jenkins instance to the cluster

    $ make deploy_<project_full_name>

### Clean up build artifacts

    $ make clean_<project_full_name>

### For all projects at once

    $ make all_images
    $ make push_all_images
    $ make k8s_all_instances
    $ make deploy_all_instances
    $ make clean_all_instances

### Create a new Jenkins instance for a project

    $ ./jenkins-new-instance.sh <project_full_name> <project_short_name> <project_display_name>
    $ make deploy_<project_full_name>

### Create a base image for a new version of Jenkins

    $ cp -r jenkins-master-base/latest jenkins-master-base/<new_version>
    $ rm jenkins-master-base/latest
    $ ln -s jenkins-master-base/<new_version> jenkins-master-base/latest

## Utilities

### jenkins-cli.sh

Give it the folder to an instance and it will let you call any Jenkins CLI commands at the proper URL. You can get the list of available commands by running.

#### Examples

* Get the version of the running Jenkins

      $ ./jenkins-cli.sh instances/<project_full_name> version

* Reload the configuration as code configuration file. Note that the config map is not immediately updated on the node running the instance after it has been deployed to the cluster. You may have to wait a couple of seconds/minutes, depending on the cluster load

      $ ./jenkins-cli.sh instances/<project_full_name> reload-jcasc-configuration

* Safe restart / safe shutdown of Jenkins. All instances are configured with the ExitLifecyle, meaning that a restart is actually an shutdown, letting Kubernetes re-spawn a new container thanks to the restart policy of the StatefulSet.

      $ ./jenkins-cli.sh instances/<project_full_name> safe-shutdown
      $ ./jenkins-cli.sh instances/<project_full_name> safe-restart

* Put Jenkins into quiet mode

      $ ./jenkins-cli.sh instances/<project_full_name> quiet-down

### jenkins-hard-restart.sh

Scale down to 0 the StatefulSet running Jenkins then scale it up to 1. It makes Kubernetes re-provision the pod (it may be re-scheduled on a new node).

    $ ./jenkins-hard-restart.sh instances/<project_full_name>

## Dependencies

* [jq](http://mikefarah.github.io/yq/)
* [docker](https://www.docker.com)
* [bash 4](https://www.gnu.org/software/bash/)

## Installation

### OpenShift

* Namespace ownership check must be disabled

      $ oc env dc/router -n default ROUTER_DISABLE_NAMESPACE_OWNERSHIP_CHECK=true
