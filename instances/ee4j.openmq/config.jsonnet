local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "ee4j.openmq",
    displayName: "Eclipse OpenMQ",
  },
  jenkins+: {
    // workaround to avoid errors, when the Gerrit plugin is disabled
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
  },
}
