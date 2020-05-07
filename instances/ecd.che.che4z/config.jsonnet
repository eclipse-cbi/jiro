local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ecd.che.che4z",
    displayName: "Eclipse Che4z"
  },
  jenkins+: {
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList)
  }
}
