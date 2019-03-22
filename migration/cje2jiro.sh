#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"

project_name="${1:-}"
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
  echo "Copy exported tar.gz from pod ${short_name}-0 in cje namespace..."
  oc rsync ${short_name}-0:/tmp/cje-migration-${project_name}.tar.gz ${work_dir}/ -n=cje
  echo "Extract tar.gz..."
  tar xzf ${work_dir}/cje-migration-${project_name}.tar.gz -C ${work_dir}
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
  oc rsync ${work_dir}/tmp/ ${short_name}-0:/var/jenkins_home/ -n=${short_name}
  rm -rf ${work_dir}/tmp
}

copy_sonar_gerrit_templates() {
  mkdir -p ${short_name}/tmp
  printf "\nCreate SonarQube config template...\n"
  cat <<EOF > ${short_name}/tmp/hudson.plugins.sonar.SonarGlobalConfiguration.xml
<?xml version='1.0' encoding='UTF-8'?>
<hudson.plugins.sonar.SonarGlobalConfiguration plugin="sonar@2.6.1">
  <installations>
    <hudson.plugins.sonar.SonarInstallation>
      <name>Eclipse Sonar</name>
      <serverUrl>https://sonar.eclipse.org</serverUrl>
      <serverVersion>5.1</serverVersion>
      <serverAuthenticationToken></serverAuthenticationToken>
      <mojoVersion>3.3.0.603</mojoVersion>
      <databaseUrl>jdbc:mysql://dbmaster:3306/sonar?autoReconnect=true&amp;useUnicode=true&amp;characterEncoding=utf8</databaseUrl>
      <databaseLogin>sonar_rw</databaseLogin>
      <additionalProperties></additionalProperties>
      <additionalAnalysisProperties></additionalAnalysisProperties>
      <triggers>
        <skipScmCause>false</skipScmCause>
        <skipUpstreamCause>false</skipUpstreamCause>
        <envVar></envVar>
      </triggers>
      <sonarLogin></sonarLogin>
      <databaseSecret></databaseSecret>
      <sonarSecret></sonarSecret>
    </hudson.plugins.sonar.SonarInstallation>
  </installations>
  <buildWrapperEnabled>true</buildWrapperEnabled>
</hudson.plugins.sonar.SonarGlobalConfiguration>
EOF

  echo "Create Gerrit config template..."
  cat <<EOG > ${short_name}/tmp/gerrit-trigger.xml
<?xml version="1.0" encoding="UTF-8"?>
<com.sonyericsson.hudson.plugins.gerrit.trigger.PluginImpl plugin="gerrit-trigger@2.23.2">
  <servers class="java.util.concurrent.CopyOnWriteArrayList">
    <com.sonyericsson.hudson.plugins.gerrit.trigger.GerritServer>
      <name>Eclipse Gerrit</name>
      <noConnectionOnStartup>false</noConnectionOnStartup>
      <config class="com.sonyericsson.hudson.plugins.gerrit.trigger.config.Config">
        <gerritHostName>gerrit-local</gerritHostName>
        <gerritSshPort>29418</gerritSshPort>
        <gerritProxy/>
        <gerritUserName>genie.${short_name}</gerritUserName>
        <gerritEMail/>
        <gerritAuthKeyFile>/run/secrets/jenkins/ssh/id_rsa</gerritAuthKeyFile>
        <gerritAuthKeyFilePassword></gerritAuthKeyFilePassword>
        <useRestApi>false</useRestApi>
        <restCodeReview>false</restCodeReview>
        <restVerified>false</restVerified>
        <gerritVerifiedCmdBuildSuccessful>gerrit review &lt;CHANGE&gt;,&lt;PATCHSET&gt; --message 'Build Successful &lt;BUILDS_STATS&gt;' --verified &lt;VERIFIED&gt; --code-review &lt;CODE_REVIEW&gt;</gerritVerifiedCmdBuildSuccessful>
        <gerritVerifiedCmdBuildUnstable>gerrit review &lt;CHANGE&gt;,&lt;PATCHSET&gt; --message 'Build Unstable &lt;BUILDS_STATS&gt;' --verified &lt;VERIFIED&gt; --code-review &lt;CODE_REVIEW&gt;</gerritVerifiedCmdBuildUnstable>
        <gerritVerifiedCmdBuildFailed>gerrit review &lt;CHANGE&gt;,&lt;PATCHSET&gt; --message 'Build Failed &lt;BUILDS_STATS&gt;' --verified &lt;VERIFIED&gt; --code-review &lt;CODE_REVIEW&gt;</gerritVerifiedCmdBuildFailed>
        <gerritVerifiedCmdBuildStarted>gerrit review &lt;CHANGE&gt;,&lt;PATCHSET&gt; --message 'Build Started &lt;BUILDURL&gt; &lt;STARTED_STATS&gt;' --verified &lt;VERIFIED&gt; --code-review &lt;CODE_REVIEW&gt;</gerritVerifiedCmdBuildStarted>
        <gerritVerifiedCmdBuildNotBuilt>gerrit review &lt;CHANGE&gt;,&lt;PATCHSET&gt; --message 'No Builds Executed &lt;BUILDS_STATS&gt;' --verified &lt;VERIFIED&gt; --code-review &lt;CODE_REVIEW&gt;</gerritVerifiedCmdBuildNotBuilt>
        <gerritFrontEndUrl>https://git.eclipse.org/r/</gerritFrontEndUrl>
        <gerritBuildStartedVerifiedValue>0</gerritBuildStartedVerifiedValue>
        <gerritBuildSuccessfulVerifiedValue>1</gerritBuildSuccessfulVerifiedValue>
        <gerritBuildFailedVerifiedValue>-1</gerritBuildFailedVerifiedValue>
        <gerritBuildUnstableVerifiedValue>0</gerritBuildUnstableVerifiedValue>
        <gerritBuildNotBuiltVerifiedValue>0</gerritBuildNotBuiltVerifiedValue>
        <gerritBuildStartedCodeReviewValue>0</gerritBuildStartedCodeReviewValue>
        <gerritBuildSuccessfulCodeReviewValue>0</gerritBuildSuccessfulCodeReviewValue>
        <gerritBuildFailedCodeReviewValue>0</gerritBuildFailedCodeReviewValue>
        <gerritBuildUnstableCodeReviewValue>-1</gerritBuildUnstableCodeReviewValue>
        <gerritBuildNotBuiltCodeReviewValue>0</gerritBuildNotBuiltCodeReviewValue>
        <enableManualTrigger>true</enableManualTrigger>
        <enablePluginMessages>true</enablePluginMessages>
        <buildScheduleDelay>3</buildScheduleDelay>
        <dynamicConfigRefreshInterval>30</dynamicConfigRefreshInterval>
        <enableProjectAutoCompletion>true</enableProjectAutoCompletion>
        <projectListRefreshInterval>3600</projectListRefreshInterval>
        <projectListFetchDelay>0</projectListFetchDelay>
        <categories class="linked-list">
          <com.sonyericsson.hudson.plugins.gerrit.trigger.VerdictCategory>
            <verdictValue>Code-Review</verdictValue>
            <verdictDescription>Code Review</verdictDescription>
          </com.sonyericsson.hudson.plugins.gerrit.trigger.VerdictCategory>
          <com.sonyericsson.hudson.plugins.gerrit.trigger.VerdictCategory>
            <verdictValue>Verified</verdictValue>
            <verdictDescription>Verified</verdictDescription>
          </com.sonyericsson.hudson.plugins.gerrit.trigger.VerdictCategory>
        </categories>
        <replicationConfig>
          <enableReplication>false</enableReplication>
          <slaves class="linked-list"/>
          <enableSlaveSelectionInJobs>false</enableSlaveSelectionInJobs>
        </replicationConfig>
        <watchdogTimeoutMinutes>0</watchdogTimeoutMinutes>
        <watchTimeExceptionData>
          <daysOfWeek/>
          <timesOfDay class="linked-list"/>
        </watchTimeExceptionData>
        <notificationLevel>ALL</notificationLevel>
        <buildCurrentPatchesOnly>
          <enabled>false</enabled>
          <abortNewPatchsets>false</abortNewPatchsets>
          <abortManualPatchsets>false</abortManualPatchsets>
        </buildCurrentPatchesOnly>
      </config>
    </com.sonyericsson.hudson.plugins.gerrit.trigger.GerritServer>
  </servers>
  <pluginConfig>
    <numberOfReceivingWorkerThreads>3</numberOfReceivingWorkerThreads>
    <numberOfSendingWorkerThreads>1</numberOfSendingWorkerThreads>
    <replicationCacheExpirationInMinutes>360</replicationCacheExpirationInMinutes>
  </pluginConfig>
</com.sonyericsson.hudson.plugins.gerrit.trigger.PluginImpl>
EOG
  echo "Copy files to Jiro pod..."
  oc rsync ${short_name}/tmp/ ${short_name}-0:/var/jenkins_home/ -n=${short_name}
  rm -rf ${short_name}/tmp
  echo "Force restart of Jenkins..."
  oc delete pod ${short_name}-0 -n=${short_name}
}

#TODO: scp oi_jipp_export.sh hipp1:/tmp/
# pause

copy_jobs
#TODO:
#import_views
copy_sonar_gerrit_templates


