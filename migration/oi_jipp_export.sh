#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
#script_name="$(basename "${BASH_SOURCE[0]}")"

# run in genie home dir
cje_tmp_dir=cje_tmp
xmlstarlet_bin=xml

# check that user is a genie user
if [[ "$USER" != genie* ]]; then
  printf "This script must be executed as a genie user! Exiting...\n"
  exit 1
fi

project_name="${USER#genie.}"
printf "Project name: %s\n" "${project_name}"

job_config_tar="jenkins-${project_name}-jobs.tar.gz"
cje_migration_tar="cje-migration-${project_name}.tar.gz"


get_job_configs() {
  printf "Collecting job configs..."
  mkdir -p "${cje_tmp_dir}/jobs/"
  # collect and filter job configs
  tar czf "${cje_tmp_dir}/${job_config_tar}" -C "/jobs/genie.${project_name}/" . --exclude='*/workspace*' --exclude='*/javadoc' --exclude='*/builds/*/jacoco' --exclude='*/builds/*/archive'
  # extract again
  tar xzf "${cje_tmp_dir}/${job_config_tar}" -C "${cje_tmp_dir}/jobs/"
  rm "${cje_tmp_dir}/${job_config_tar}"
  printf "Done.\n"
}

check_git_file_urls() {
  grep "${cje_tmp_dir}/jobs/*/config.xml" -e "<url>/gitroot" -e "<url>file:///gitroot" -e "git clone file:///gitroot" -e "git clone /gitroot"
}

convert_git_file_urls() {
  echo "The following jobs use Git file URLs:"
  check_git_file_urls || true

  echo "Trying to convert them..."
  # convert file urls to git urls
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/<url>\/gitroot/<url>git:\/\/git.eclipse.org\/gitroot/g' {} \;
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/<url>file:\/\/\/gitroot/<url>git:\/\/git.eclipse.org\/gitroot/g' {} \;
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/git clone \/gitroot/git clone git:\/\/git.eclipse.org\/gitroot/g' {} \;
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/git clone file:\/\/\/gitroot/git clone git:\/\/git.eclipse.org\/gitroot/g' {} \;

  echo "Check after conversion (should not show anything):"
  check_git_file_urls || true
}

convert_tools() {
  printf "Adapting paths to tools (JDK, Maven)...\n"
  ## Tools
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/<jdk>jdk1.\(5\|6\|7\|8\).0-latest/<jdk>oracle-jdk\1-latest/g' {} \;
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/<jdk>jdk9-latest/<jdk>oracle-jdk9-latest/g' {} \;
  # TODO: JDK > 9

  # Find remaining JDK tool definitions
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec grep '<jdk>jdk' {} \;

  # replace all Maven versions except 3.2.5, 3.3.9 and 3.5.4 with "latest"
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i '/<mavenName>apache-maven-\(3.2.5\|3.3.9\|3.5.4\)/! s/<mavenName>apache-maven-[^<]*/<mavenName>apache-maven-latest/g' {} \;

  ## Shell build steps
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/\/shared\/common\/jdk1.\(5\|6\|7\|8\).0-latest/\/opt\/tools\/java\/oracle\/jdk-\1\/latest/g' {} \;
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/\/shared\/common\/jdk9-latest/\/opt\/tools\/java\/oracle\/jdk-9\/latest/g' {} \;
  # TODO: JDK > 9

  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i 's/\/shared\/common\/apache-maven-\(3.2.5\|3.3.9\|3.5.4\|latest\)/\/opt\/tools\/apache-maven\/\1/g' {} \;
  # replace all Maven versions except 3.2.5, 3.3.9 and 3.5.4 with "latest"
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec sed -i '/\/shared\/common\/apache-maven-\(3.2.5\|3.3.9\|3.5.4\)/! s/\/shared\/common\/apache-maven-[^\/\ ]*/\/opt\/tools\/apache-maven\/latest/g' {} \;

  # Find remaining links to /shared/common
  find "${cje_tmp_dir}"/jobs/*/ -name config.xml -exec grep '/shared/common/' {} \;

  printf "Done.\n"
}

extract_views() {
  printf "Extracting views..."
  # TODO: Don't extract views, if there are none (other than the all view)
  "${xmlstarlet_bin}" sel -t -c "/hudson/views/*" .jenkins/config.xml > "${cje_tmp_dir}/views.xml"
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
  newPluginsHpi=$(find .jenkins/plugins -name *.hpi -exec basename {} .hpi \;)
  newPluginsJpi=$(find .jenkins/plugins -name *.jpi -exec basename {} .jpi \;)
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

check_file_size() {
  local file=$1
  local os
  os="$(uname -s)"
  if [ "${os}" == "Linux" ]; then
    filesize=$(stat -c '%s' "${file}")
  elif [ "${os}" == "Darwin" ]; then
    filesize=$(stat -f '%z' "${file}")
  else
    echo "ERROR: os is neither Linux nor Darwin: ${os}. Can not check file size of ${file}."
    exit 1
  fi
  if [ -z "${filesize}" ]; then
    echo "ERROR: filesize of ${file} is empty."
    exit 1
  fi
  if [ "${filesize}" -gt 150000000 ]; then #150MB
    echo "${file} is bigger than 150MB. Please investigate."
    exit 1
  fi
}

extract_nodes() {
  printf "Copying agent configurations (if any exist)...\n"
  cp -R .jenkins/nodes "${cje_tmp_dir}/" || :
}

tar_files() {
  printf "Taring files and copying to /tmp..."
  tar czf "${cje_migration_tar} "-C "${cje_tmp_dir}" .
  check_file_size "${cje_migration_tar}"
  cp "${cje_migration_tar}" "/tmp/"
  printf "Done.\n"
}

##MAIN

get_job_configs
convert_git_file_urls
convert_tools
extract_views
checkForExtraPlugins
extract_nodes
tar_files