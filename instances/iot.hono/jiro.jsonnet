local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("iot.hono", "Eclipse Hono") {
  "config.json"+: {
    jenkins+: {
      permissions:
        // workaround to avoid errors, when the Gerrit plugin is disabled
        permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList),
    },
  }
}