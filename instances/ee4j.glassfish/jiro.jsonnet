local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("ee4j.glassfish", "Eclipse Glassfish") {
  "config.json"+: {
    project+: {
      resourcePacks: 16
    },
    jenkins+: {
      agentConnectionTimeout: 300,
      theme: "quicksilver-light",
      // workaround to avoid errors, when the Gerrit plugin is disabled
      permissions: permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList),
      plugins+: [
        "copyartifact",
        "view-job-filters",
      ],
    }
  }
}
