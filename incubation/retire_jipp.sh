#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"

project_name="${1:-}"
short_name="${project_name##*.}"
jenkins_home="/var/jenkins"
backup_file_name="jenkins_backup-${project_name}.tar.gz"

usage() {
  printf "Usage: %s project_name\n" "$script_name"
  printf "\t%-16s full name (e.g. technology.cbi for CBI project).\n" "project_name"
}

# check that project name is not empty
if [[ -z "${project_name}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

create_retire_script() {
  rm -rf tmp
  mkdir -p tmp

  echo "Creating retire script..."
  cat <<EOF > tmp/retire.sh
#!/usr/bin/env bash
rm -rf "${jenkins_home}/backup"
mkdir -p "${jenkins_home}/backup"
pushd "${jenkins_home}/plugins"
find . -type f -name '*.jpi' > "${jenkins_home}/plugins/plugins.lst"
popd
tar -czf "${jenkins_home}/backup/${backup_file_name}" "${jenkins_home}"\
 --exclude='*/backup'\
 --exclude='*/war'\
 --exclude='*/workspace'\
 --exclude='*/updates'\
 --exclude='*/users'\
 --exclude='*/plugins/**/*'\
 --exclude='*/plugins/*.jpi*'\
 --exclude='*/plugins/*.bak'\
 --exclude='*/fingerprints'\
 --exclude='*/org.jenkinsci.plugins.github_branch_source.GitHubSCMProbe.cache'\
 --exclude='*/caches'\
 --exclude='*/.cache'\
 --exclude='*/.java'\
 --exclude='*/.groovy'\
 --exclude='*/logs'\
 --exclude='*/jobs/*/workspace*'\
 --exclude='*/jobs/*/configurations'\
 --exclude='*/jobs/*/promotions/*/builds'\
 --exclude='*/jobs/*/javadoc'\
 --exclude='*/jobs/*/builds/*/jacoco'\
 --exclude='*/jobs/*/builds/*/archive'

ls -al "${jenkins_home}/backup"
EOF

  chmod +x tmp/retire.sh
}

collect_backup() {
  echo "Copy retire script to Jiro pod ${short_name}-0..."
  oc rsync tmp/ "${short_name}-0:/var/jenkins/" -n="${short_name}" --no-perms

  echo "Collect jobs on Jiro pod ${short_name}-0..."
  oc exec -n="${short_name}" "${short_name}-0" -i -t -- chmod +x /var/jenkins/retire.sh
  oc exec -n="${short_name}" "${short_name}-0" -i -t -- /var/jenkins/retire.sh

  echo "Copy files from Jiro pod ${short_name}-0..."
  mkdir -p backup
  oc rsync -n="${short_name}" "${short_name}-0:/var/jenkins/backup/" backup/ --no-perms
}

delete_question(){
  read -p "Do you want to delete the project? (Y)es, (N)o, E(x)it: " yn
  case "${yn}" in
    [Yy]* ) delete_project;;
    [Nn]* ) echo "Skipping delete... ";return;;
    [Xx]* ) exit;;
        * ) echo "Please answer (Y)es, (N)o, E(x)it";delete_question;;
  esac
}

delete_project() {
  echo "Delete project/namespace on OpenShift..."
  oc delete project "${short_name}"
  oc delete pv "tools-jiro-${short_name}"

  echo "Delete project in Jiro..."
  rm -rf "../instances/${project_name}"
  echo "TODO: Commit changes to Jiro Git repo..."
}

create_retire_script
collect_backup

echo "Copy backup tar.gz to build:/tmp..."
scp "backup/${backup_file_name}" build:/tmp/

delete_question

echo "TODO: Remove ${project_name} from ProjectServices DB..."
echo "TODO: Move backup tar.gz from build:/tmp to build:/opt/public/hipp/archive/..."
