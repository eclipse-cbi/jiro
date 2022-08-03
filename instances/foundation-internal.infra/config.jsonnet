local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "foundation-internal.infra",
    displayName: "Eclipse Foundation Infra",
    resourcePacks: 2,
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/" + $.project.shortName,
  },
  jenkins+: {
    version: "2.332.3",
    staticAgentCount: 1,
    permissions: [
      {
        principal: "anonymous",
        grantedPermissions: [
          "Overall/Read",
        ]
      },
      {
        principal: "admins",
        grantedPermissions: ["Overall/Administer"],
      },
      {
        principal: "foundation-internal.webdev",
        grantedPermissions: ["Overall/Read"],
      },
      {
        principal: "wayne.beaton@eclipse-foundation.org",
        grantedPermissions: ["Overall/Read", "Agent/Build"],
      },
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/617
      {
        principal: "boris.baldassari@eclipse-foundation.org",
        grantedPermissions: ["Overall/Read", "Agent/Build"],
      },
      {
        principal: "foundation-internal.it",
        grantedPermissions: permissionsTemplates.committerPermissionsList,
      }
    ],
    plugins+: [
      "docker-workflow",
      "kubernetes-cli",
      "mail-watcher-plugin",
      "pipeline-github",
      "slack",
    ],
  },
  kubernetes+: {
    master+: {
      namespace: "foundation-internal-infra"
    }
  },
  secrets+: {
    "gerrit-trigger-plugin": {},
  },
}
