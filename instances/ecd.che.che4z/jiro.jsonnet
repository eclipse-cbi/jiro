local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("ecd.che.che4z", "Eclipse Che4z") {
  "config.json"+: {
    jenkins+: {
      permissions:
        // workaround to avoid errors, when the Gerrit plugin is disabled
        permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList) +
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=566607
        permissionsTemplates.projectPermissions("andrea.zaccaro@broadcom.com", ["Credentials/Create", "Credentials/Update"]),
      plugins+: [
        "embeddable-build-status",
        "copyartifact",
      ],
    }
  },
}
