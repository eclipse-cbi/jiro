local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("ee4j.openmq", "Eclipse OpenMQ") {
  "config.json"+: {
    jenkins+: {
      // workaround to avoid errors, when the Gerrit plugin is disabled
      permissions: permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList),
    },
  },
}
