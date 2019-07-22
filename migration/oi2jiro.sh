#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"

project_name="${1:-}"
hipp_name="${2:-}"
short_name=${project_name##*.}

usage() {
  printf "Usage: %s project_name hipp_name\n" "$script_name"
  printf "\t%-16s full name (e.g. technology.cbi for CBI project).\n" "project_name"
  printf "\t%-16s hipp name (e.g. hipp1).\n" "hipp_name"
}

# check that project name is not empty
if [[ -z "${project_name}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

# check that display name is not empty
if [[ -z "${hipp_name}" ]]; then
 printf "ERROR: a hipp name must be given.\n"
 usage
 exit 1
fi

# check that project name contains a dot
if [[ "$project_name" != *.* ]]; then
  printf "ERROR: the full project name with a dot must be given (e.g. technology.cbi).\n"
  usage
  exit 1
fi

copy_jobs() {
  local work_dir=${short_name}
  echo "Generate migration work directory for ${short_name}..."
  mkdir -p ${work_dir}
  echo "Copy exported tar.gz from ${hipp_name}..."
  scp ${hipp_name}:/tmp/cje-migration-${short_name}.tar.gz ${work_dir}/
  echo "Extract tar.gz..."
  tar xzf ${work_dir}/cje-migration-${short_name}.tar.gz -C ${work_dir}
  echo "Copy job directory to target Jiro pod ${short_name}-0..."
  pushd ${work_dir}
  oc rsync jobs ${short_name}-0:/var/jenkins_home/ -n=${short_name}
  popd
}

import_views() {
  local work_dir=${short_name}
  printf "\nCopy config.xml from Jiro pod ${short_name}-0...\n"
  oc rsync ${short_name}-0:/var/jenkins_home/config.xml ${work_dir}/ -n=${short_name}
  echo "Create backup of config.xml..."
  cp ${work_dir}/config.xml ${work_dir}/config.xml.bak
  printf "Merge views..."
  export views=$(<${work_dir}/views.xml)
  perl -i -0pe 's/<views>.*<\/views>/<views>$ENV{views}<\/views>/gms' ${work_dir}/config.xml
  printf "Done.\n"
  echo "Copy modified config.xml back to Jiro pod ${short_name}-0..."
  oc exec ${short_name}-0 rm /var/jenkins_home/config.xml -n=${short_name}
  mkdir -p ${work_dir}/tmp
  cp ${work_dir}/config.xml ${work_dir}/tmp/
  oc rsync ${work_dir}/tmp/ ${short_name}-0:/var/jenkins_home/ -n=${short_name} --no-perms
  rm -rf ${work_dir}/tmp
}

#TODO: scp oi_jipp_export.sh hipp1:/tmp/
# pause

copy_jobs
import_views

