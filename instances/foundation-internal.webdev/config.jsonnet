local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "foundation-internal.webdev",
    displayName: "Eclipse Foundation WebDev",
    resourcePacks: 5,
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/"+ $.project.shortName,
  },
  jenkins+: {
    version: "2.303.3",
    staticAgentCount: 1,
    permissions: [
      {
        principal: "anonymous",
        grantedPermissions: [
          "Overall/Read",
        ]
      },
      {
        principal: $.project.unixGroupName,
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger",],
      },
      {
        principal: "admins",
        grantedPermissions: ["Overall/Administer"],
      },
    ],
    plugins+: [
      "docker-workflow",
      "kubernetes-cli",
      "mail-watcher-plugin",
      "openshift-client",
      "slack",
    ],
  },
  kubernetes+: {
    master+: {
      namespace: "foundation-internal-webdev"
    }
  },
  secrets+: {
    "gerrit-trigger-plugin": {},
  },
}
