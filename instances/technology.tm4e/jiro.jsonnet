local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("technology.tm4e", "Eclipse TM4E") {
  "config.json"+: {
    jenkins+: {
      permissions: permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList)
    }
  },
}
