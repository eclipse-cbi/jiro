local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("adoptium.temurin-compliance", "Eclipse Temurin Compliance") {
  "config.json"+: {
    jenkins+: {
      staticAgentCount: 10,
      permissions: [
        {
          principal: "admins",
          grantedPermissions: ["Overall/Administer"],
        },
        {
          principal: $["config.json"].project.unixGroupName,
          grantedPermissions: permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect", "Agent/ExtendedRead"],
        },
      ],
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
        "pipeline-utility-steps",
        "slack",
        "tap",
        "build-with-parameters",
        "xvfb",
        "monitoring ",
        "xunit",
      ],
    },
  },
}
