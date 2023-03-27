#!/usr/bin/env bash
rm -rf "/var/jenkins/backup"
mkdir -p "/var/jenkins/backup"
pushd "/var/jenkins/plugins"
find . -type f -name '*.jpi' > "/var/jenkins/plugins/plugins.lst"
popd
tar -czf "/var/jenkins/backup/jenkins_backup-iot.concierge.tar.gz" --exclude='*/backup' --exclude='*/war' --exclude='*/workspace' --exclude='*/updates' --exclude='*/users' --exclude='*/plugins/**/*' --exclude='*/plugins/*.jpi*' --exclude='*/plugins/*.bak' --exclude='*/fingerprints' --exclude='*/org.jenkinsci.plugins.github_branch_source.GitHubSCMProbe.cache' --exclude='*/caches' --exclude='*/.cache' --exclude='*/.java' --exclude='*/.groovy' --exclude='*/logs' --exclude='*/jobs/*/workspace*' --exclude='*/jobs/*/configurations' --exclude='*/jobs/*/promotions/*/builds' --exclude='*/jobs/*/javadoc' --exclude='*/jobs/*/builds/*/jacoco' --exclude='*/jobs/*/builds/*/archive' "/var/jenkins"

ls -al "/var/jenkins/backup"
