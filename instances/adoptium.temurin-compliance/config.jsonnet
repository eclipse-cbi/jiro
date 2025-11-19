local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "adoptium.temurin-compliance",
    displayName: "Eclipse Temurin Compliance",

  },
  jenkins+: {
    staticAgentCount: 26,
    permissions:
      permissionsTemplates.group("admins", ["Overall/Administer"]) +
      permissionsTemplates.group($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect", "Agent/ExtendedRead"]) +
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/1673
      permissionsTemplates.user("tc-trigger-bot@eclipse.org", ["Overall/Read", "Job/Read", "Job/Build", "Agent/Build"])
    ,
    plugins+: [
      "artifactory",
      "build-user-vars-plugin",
      "build-with-parameters",
      "copyartifact",
      "embeddable-build-status",
      "generic-webhook-trigger",
      "groovy-postbuild",
      "http_request",
      "jira",
      "job-dsl",
      "monitoring ",
      "parameter-separator",
      "Parameterized-Remote-Trigger",
      "pipeline-utility-steps",
      "slack",
      "tap",
      "view-job-filters",
      "xvfb",
      "xunit",
    ],
  },
  storage: {
    quota:"200Gi",
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c55,c15",
}
