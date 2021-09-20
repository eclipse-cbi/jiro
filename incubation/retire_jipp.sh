#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_FOLDER="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

PROJECT_NAME="${1:-}"
SHORT_NAME="${PROJECT_NAME##*.}"
BACKUP_FILE_NAME="jenkins_backup-${PROJECT_NAME}.tar.gz"

usage() {
  printf "Usage: %s project_name\n" "${SCRIPT_NAME}"
  printf "\t%-16s full name (e.g. technology.cbi for CBI project).\n" "project_name"
}

# check that project name is not empty
if [[ -z "${PROJECT_NAME}" ]]; then
 printf "ERROR: a project name must be given.\n"
 usage
 exit 1
fi

if [[ ! -f "${SCRIPT_FOLDER}/../.localconfig" ]]; then
  echo "ERROR: File '$(readlink -f "${SCRIPT_FOLDER}/../.localconfig")' does not exists"
  echo "Create one to configure db and file server credentials. Example:"
  echo '{"db_server": {"server": "myserver", "user": "user", "pw": "<path in pass>", "mysql_user": "username", "mysql_pw": "<path in pass>"},"file_server": {"server": "myserver2", "user": "user2", "pw": "<path in pass>", "pw_root": "<path in pass>"}}' | jq -M
fi

FILE_SERVER="$(jq -r '.["file_server"]["server"]' "${SCRIPT_FOLDER}/../.localconfig")"
FILE_SERVER_USER="$(jq -r '.["file_server"]["user"]' "${SCRIPT_FOLDER}/../.localconfig")"
FILE_SERVER_PW="$(jq -r '.["file_server"]["pw"]' "${SCRIPT_FOLDER}/../.localconfig")"
FILE_SERVER_PW_ROOT="$(jq -r '.["file_server"]["pw_root"]' "${SCRIPT_FOLDER}/../.localconfig")"

DB_SERVER="$(jq -r '.["db_server"]["server"]' "${SCRIPT_FOLDER}/../.localconfig")"
DB_SERVER_USER="$(jq -r '.["db_server"]["user"]' "${SCRIPT_FOLDER}/../.localconfig")"
DB_SERVER_PW="$(jq -r '.["db_server"]["pw"]' "${SCRIPT_FOLDER}/../.localconfig")"
DB_SERVER_MYSQL_USER="$(jq -r '.["db_server"]["mysql_user"]' "${SCRIPT_FOLDER}/../.localconfig")"
DB_SERVER_MYSQL_PW="$(jq -r '.["db_server"]["mysql_pw"]' "${SCRIPT_FOLDER}/../.localconfig")"

create_retire_script() {
  local short_name="${1:-}"
  local backup_file_name="${2:-}"
  local jenkins_home="/var/jenkins"
  mkdir -p tmp

  echo "Creating retire script..."
  cat <<EOF > tmp/retire.sh
#!/usr/bin/env bash
rm -rf "${jenkins_home}/backup"
mkdir -p "${jenkins_home}/backup"
pushd "${jenkins_home}/plugins"
find . -type f -name '*.jpi' > "${jenkins_home}/plugins/plugins.lst"
popd
tar -czf "${jenkins_home}/backup/${backup_file_name}"\
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
 --exclude='*/jobs/*/builds/*/archive'\
 "${jenkins_home}"

ls -al "${jenkins_home}/backup"
EOF

  chmod +x tmp/retire.sh

  echo "Copying retire script to Jiro pod ${short_name}-0..."
  oc rsync tmp/ "${short_name}-0:/var/jenkins/" -n="${short_name}" --no-perms
  oc exec -n="${short_name}" "${short_name}-0" -i -t -- chmod +x /var/jenkins/retire.sh

  rm -rf tmp
}

collect_backup() {
  local short_name="${1:-}"
  echo "Collecting jobs on Jiro pod ${short_name}-0..."

  oc exec -n="${short_name}" "${short_name}-0" -i -t -- /var/jenkins/retire.sh

  echo "Copying files from Jiro pod ${short_name}-0..."
  mkdir -p backup
  oc rsync -n="${short_name}" "${short_name}-0:/var/jenkins/backup/" backup/ --no-perms
}

delete_question(){
  local project_name="${1:-}"
  read -p "Do you want to delete the project? (Y)es, (N)o, E(x)it: " yn
  case "${yn}" in
    [Yy]* ) delete_project "${project_name}";;
    [Nn]* ) echo "Skipping delete... ";return;;
    [Xx]* ) exit;;
        * ) echo "Please answer (Y)es, (N)o, E(x)it";delete_question "${project_name}";;
  esac
}

delete_project() {
  local project_name="${1:-}"
  local short_name="${project_name##*.}"
  echo "Deleting project/namespace on OpenShift..."
  oc delete project "${short_name}"
  oc delete pv "tools-jiro-${short_name}"

  echo "Deleting project in Jiro..."
  rm -rf "../instances/${project_name}"
  echo "TODO: Commit changes to Jiro Git repo..."
}

remove_jipp_from_db() {
  local project_name="${1:-}"

  local user="${DB_SERVER_USER}"
  local server="${DB_SERVER}"
  local pw="${DB_SERVER_PW}"
  local mysqlUser="${DB_SERVER_MYSQL_USER}"
  local mysqlPw="${DB_SERVER_MYSQL_PW}"

  local userPrompt="$user@$server:~> *"
  local passwordPrompt="\[Pp\]assword:*"
  local mysqlPasswordPrompt="Enter \[Pp\]assword: *"
  local mysqlPrompt="MariaDB \[eclipsefoundation\]> *"
  local mysqlDeleteQuery="DELETE FROM ProjectServices WHERE ProjectID = \\\"$project_name\\\";"
  local mysqlQuery="SELECT * FROM ProjectServices WHERE ProjectID=\\\"$project_name\\\";"

  echo "Removing ${project_name} from ProjectServices DB..."

  expect -c "
  #5 seconds timeout
  set timeout 5

  # ssh to remote
  spawn ssh $user@$server

  expect {
    -re \"$passwordPrompt\" {
      send  \"$pw\r\"
      exp_continue
    }
    #TODO: only works one time
    -re \"passphrase\" {
      interact -o \"\r\" return
    }
  }
  expect -re \"$userPrompt\"

  # use mysql
  send \"mysql -u $mysqlUser -p -h foundation eclipsefoundation\r\"
  interact -o -nobuffer -re \"$mysqlPasswordPrompt\" return
  send \"[exec pass $mysqlPw]\r\"
  expect -re \"$mysqlPrompt\"

  send \"$mysqlDeleteQuery\r\"
  expect -re \"Query OK, 1 row affected*\"

  send \"$mysqlQuery\r\"
  #TODO: fail if expect fails?
  expect -re \"Empty set*\"

  # exit mysql and ssh
  send \"exit\rexit\r\"
  expect eof
"
}

mv_jipp_backup_to_archive() {
  local short_name="${1:-}"
  local file_name="${2:-}"

  local genie_user="genie.${short_name}"

  local server="${FILE_SERVER}"
  local user="${FILE_SERVER_USER}"
  local pw="${FILE_SERVER_PW}"
  local pwRoot="${FILE_SERVER_PW_ROOT}"

  local userPrompt="$user@$server:~> *"
  local passwordPrompt="\[Pp\]assword: *"
  local serverRootPrompt="$server:~ # *"

  local archive_folder="/opt/public/hipp/archive/${genie_user}"

  echo "Moving backup from /tmp/${file_name} to ${archive_folder}/..."

  expect -c "
  #5 seconds timeout
  set timeout 5

  # ssh to remote
  spawn ssh $user@$server

  expect {
    -re \"$passwordPrompt\" {
      send [exec pass $pw]\r
    }
    #TODO: only works one time
    -re \"passphrase\" {
      interact -o \"\r\" return
    }
  }
  expect -re \"$userPrompt\"

  # su to root
  send \"su -\r\"
  interact -o -nobuffer -re \"$passwordPrompt\" return
  send [exec pass $pwRoot]\r
  expect -re \"$serverRootPrompt\"

  # move file
  send \"mkdir -p $archive_folder/\r\"
  send \"mv /tmp/$file_name $archive_folder/\r\"
  send \"ls -al $archive_folder\r\"

  # exit su, exit su and exit ssh
  send \"exit\rexit\rexit\r\"
  expect eof
"
}

# Main

create_retire_script "${SHORT_NAME}" "${BACKUP_FILE_NAME}"

collect_backup "${SHORT_NAME}"

echo "Copying backup tar.gz to ${FILE_SERVER}:/tmp..."
scp "backup/${BACKUP_FILE_NAME}" "${FILE_SERVER}:/tmp/"

delete_question "${PROJECT_NAME}"

remove_jipp_from_db "${PROJECT_NAME}"

mv_jipp_backup_to_archive "${SHORT_NAME}" "${BACKUP_FILE_NAME}"

echo "TODO:"
echo "- commit and push changes to jiro repo"
echo "- comment on Bugzilla ticket"
