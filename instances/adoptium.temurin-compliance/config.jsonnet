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
      permissionsTemplates.group($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect", "Agent/ExtendedRead"])
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
}
