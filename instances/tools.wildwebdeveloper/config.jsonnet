local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "tools.wildwebdeveloper",
    displayName: "Eclipse Wild Web Developer"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList)
  }
}
