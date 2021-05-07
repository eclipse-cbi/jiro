local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "adoptium.temurin-compliance",
    displayName: "Eclipse Temurin Compliance",
  },
  jenkins+: {
    permissions: [
      {
        principal: "admins",
        grantedPermissions: ["Overall/Administer"],
      },
      {
        principal: "slambert@gmail.com",
        grantedPermissions: permissionsTemplates.committerPermissionsList,
      },
      {
        principal: "sxa@redhat.com",
        grantedPermissions: permissionsTemplates.committerPermissionsList,
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
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  }
}
