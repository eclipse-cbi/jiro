#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
#script_name="$(basename "${BASH_SOURCE[0]}")"

# run in tmp dir on cje pod

project_name=${1:-}

if [[ -z "${project_name}" ]]; then
  printf "ERROR: project name must not be empty\n"
  exit 1
fi

printf "Project name: %s\n" "${project_name}"

cje_tmp_dir=/tmp/cje_tmp
jenkins_home=/var/jenkins
jobs_dir="${jenkins_home}/jobs"
job_config_tar="jenkins-${project_name}-jobs.tar.gz"
cje_migration_tar="cje-migration-${project_name}.tar.gz"

#clean cje_tmp_dir
if [ -d "${cje_tmp_dir}" ]; then
  printf "\nDeleting temp dir...\n\n"
  rm -rf "${cje_tmp_dir}"
fi

get_job_configs() {
  printf "Collecting job configs..."
  mkdir -p "${cje_tmp_dir}/jobs/"
  # collect and filter job configs
  tar czf "${cje_tmp_dir}/${job_config_tar}" -C "${jobs_dir}/" . --exclude='*/workspace*' --exclude='*/javadoc' --exclude='*/builds/*/jacoco' --exclude='*/builds/*/archive' --exclude='*/branches/*/builds/*/archive'
  # extract again
  tar xzf "${cje_tmp_dir}/${job_config_tar}" -C "${cje_tmp_dir}/jobs/"
  rm "${cje_tmp_dir}/${job_config_tar}"
  printf "Done.\n"
}

extract_views() {
  printf "Extracting views..."
  # TODO: Don't extract views, if there are none (other than the all view)
  cp "${jenkins_home}/config.xml" "${cje_tmp_dir}/"
  printf "Done.\n"
}

checkForExtraPlugins() {
  printf "Checking for additional plugins..."
  # this list includes plugins like pam-auth and matrix-auth that are not installed in CJE MMs, but should not show up in the results
  defaultPlugins="
ace-editor
analysis-core
ant
antisamy-markup-formatter
apache-httpcomponents-client-4-api
authentication-tokens
bouncycastle-api
branch-api
build-timeout
cloudbees-folder
command-launcher
conditional-buildstep
config-file-provider
configuration-as-code
configuration-as-code-support
credentials
credentials-binding
display-url-api
docker-commons
docker-workflow
durable-task
email-ext
extended-read-permission
extra-columns
findbugs
gerrit-trigger
ghprb
git
git-client
git-parameter
git-server
github
github-api
greenballs
handlebars
jackson2-api
javadoc
jdk-tool
jobConfigHistory
jquery
jquery-detached
jsch
junit
kubernetes
kubernetes-credentials
ldap
lockable-resources
mailer
matrix-auth
matrix-project
maven-plugin
momentjs
parameterized-trigger
pipeline-build-step
pipeline-graph-analysis
pipeline-input-step
pipeline-maven
pipeline-milestone-step
pipeline-model-api
pipeline-model-declarative-agent
pipeline-model-definition
pipeline-model-extensions
pipeline-rest-api
pipeline-stage-step
pipeline-stage-tags-metadata
pipeline-stage-view
plain-credentials
promoted-builds
rebuild
resource-disposer
run-condition
scm-api
script-security
simple-theme-plugin
sonar
ssh-agent
ssh-credentials
ssh-slaves
structs
timestamper
token-macro
variant
windows-slaves
workflow-aggregator
workflow-api
workflow-basic-steps
workflow-cps
workflow-cps-global-lib
workflow-durable-task-step
workflow-job
workflow-multibranch
workflow-scm-step
workflow-step-api
workflow-support
ws-cleanup
xvnc
"
  # add defaultPlugins twice to filter out false positives
  newPluginsHpi=$(find "${jenkins_home}/plugins" -name *.hpi -exec basename {} .hpi \;)
  newPluginsJpi=$(find "${jenkins_home}/plugins" -name *.jpi -exec basename {} .jpi \;)
  extraPlugins=$(echo -e "${defaultPlugins}\n${defaultPlugins}\n${newPluginsHpi}\n${newPluginsJpi}" | sort | uniq -u)
  if [ "$extraPlugins" != "" ]; then
    printf "\n"
    echo "Additional plugins that should be installed:"
    echo -e "$extraPlugins\n"
    echo -e "$extraPlugins\n" > "${cje_tmp_dir}/additional_plugins.txt"
  else
    printf "Done.\n"
  fi
}

tar_files() {
  printf "Taring files..."
  tar czf "/tmp/${cje_migration_tar}" -C "${cje_tmp_dir}" .
  printf "Done.\n"
}

##MAIN

get_job_configs
extract_views
checkForExtraPlugins
tar_files