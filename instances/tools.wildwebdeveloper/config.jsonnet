local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "tools.wildwebdeveloper",
    shortName: "wildwebdeveloper",
    displayName: "Eclipse Wild Web Developer"
  },
  jenkins+: {
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList)
  }
}
