local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("foundation-internal.webdev", "Eclipse Foundation WebDev") {
  "config.json"+: {
    project+: {
      resourcePacks: 5,
    },
    deployment+: {
      host: "foundation.eclipse.org",
      prefix: "/ci/"+ $["config.json"].project.shortName,
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
          principal: $["config.json"].project.unixGroupName,
          grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger",],
        },
        {
          principal: "admins",
          grantedPermissions: ["Overall/Administer"],
        },
      ],
      plugins+: [
        "disable-failed-job",
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
}
