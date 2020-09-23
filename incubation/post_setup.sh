#!/usr/bin/env bash

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${BASH_SOURCE[0]})"

project_name="${1:-}"
short_name=${project_name##*.}

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

create_and_copy_templates() {
  mkdir -p tmp

  echo "Creating Gerrit config template..."
  cat <<EOG > tmp/gerrit-trigger.xml
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

  echo "Creating Xvnc config template..."
  xvnc_commandline='Xvnc :$DISPLAY_NUMBER -geometry 1024x768 -depth 24 -ac -SecurityTypes none -noreset'
  cat <<EOH > tmp/hudson.plugins.xvnc.Xvnc.xml
<?xml version='1.1' encoding='UTF-8'?>
<hudson.plugins.xvnc.Xvnc_-DescriptorImpl plugin="xvnc@1.24">
  <xvnc>${xvnc_commandline}</xvnc>
  <minDisplayNumber>10</minDisplayNumber>
  <maxDisplayNumber>99</maxDisplayNumber>
  <skipOnWindows>true</skipOnWindows>
  <cleanUp>true</cleanUp>
  <allocators>
  </allocators>
</hudson.plugins.xvnc.Xvnc_-DescriptorImpl>
EOH

  echo "Creating credentials template..."
  cat <<EOI > tmp/credentials.xml
<?xml version='1.1' encoding='UTF-8'?>
<com.cloudbees.plugins.credentials.SystemCredentialsProvider plugin="credentials@2.1.18">
  <domainCredentialsMap class="hudson.util.CopyOnWriteMap\$Hash">
    <entry>
      <com.cloudbees.plugins.credentials.domains.Domain>
        <specifications/>
      </com.cloudbees.plugins.credentials.domains.Domain>
      <java.util.concurrent.CopyOnWriteArrayList>
        <com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey plugin="ssh-credentials@1.16">
          <scope>GLOBAL</scope>
          <id>projects-storage.eclipse.org-bot-ssh</id>
          <description>ssh://genie.${short_name}@projects-storage.eclipse.org</description>
          <username>genie.${short_name}</username>
          <passphrase></passphrase>
          <privateKeySource class="com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource">
            <privateKey>
            </privateKey>
          </privateKeySource>
        </com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey>
      </java.util.concurrent.CopyOnWriteArrayList>
    </entry>
  </domainCredentialsMap>
</com.cloudbees.plugins.credentials.SystemCredentialsProvider>
EOI

  echo "Copy files to Jiro pod ${short_name}-0..."
  oc rsync tmp/ ${short_name}-0:/var/jenkins/ -n=${short_name} --no-perms
  rm -rf tmp
  echo "Force restart of Jenkins..."
  oc delete pod ${short_name}-0 -n=${short_name}
}

create_and_copy_templates
