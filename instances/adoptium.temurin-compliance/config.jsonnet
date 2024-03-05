local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "adoptium.temurin-compliance",
    displayName: "Eclipse Temurin Compliance",

  },
  jenkins+: {
    staticAgentCount: 10,
    permissions:
      permissionsTemplates.group("admins", ["Overall/Administer"]) +
      permissionsTemplates.group($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect", "Agent/ExtendedRead"])
    ,
    plugins+: [
      "artifactory",
      "badge",
      "build-user-vars-plugin",
      "copyartifact",
      "embeddable-build-status",
      "generic-webhook-trigger",
      "groovy-postbuild",
      "http_request",
      "jira",
      "job-dsl",
      "parameter-separator",
      "Parameterized-Remote-Trigger",
      "pipeline-utility-steps",
      "slack",
      "tap",
      "build-with-parameters",
      "view-job-filters",
      "xvfb",
      "monitoring ",
      "xunit",
    ],
  },
}
