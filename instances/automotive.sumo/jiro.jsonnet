local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("automotive.sumo", "Eclipse SUMO") {
  "config.json"+: {
    project+: {
      resourcePacks: 2,
    },
    jenkins+: {
      // workaround to avoid errors, when the Gerrit plugin is disabled
      permissions: permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList)
    },
  },
}
