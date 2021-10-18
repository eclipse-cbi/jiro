local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("foundation-internal.infra", "Eclipse Foundation Infra") {
  "config.json"+: {
    deployment+: {
      host: "foundation.eclipse.org",
      prefix: "/ci/" + $["config.json"].project.shortName,
    },
    jenkins+: {
      version: "2.303.3",
      staticAgentCount: 1,
      permissions: [
        {
          principal: "admins",
          grantedPermissions: ["Overall/Administer"],
        },
        {
          principal: "foundation-internal.webdev",
          grantedPermissions: [ "Overall/Read" ],
        },
        {
          principal: "wayne.beaton@eclipse-foundation.org",
          grantedPermissions: [ "Overall/Read" ],
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
  },
}
