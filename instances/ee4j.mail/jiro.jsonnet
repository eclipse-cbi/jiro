local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("ee4j.mail", "Jakarta Mail") {
  "config.json"+: {
    jenkins+: {
      theme: "quicksilver-light",
      // workaround to avoid errors, when the Gerrit plugin is disabled
      permissions: permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList),
      plugins+: [
        "copyartifact",
      ],
    }
  }
}
