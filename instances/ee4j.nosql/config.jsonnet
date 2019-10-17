local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ee4j.nosql",
    shortName: "nosql",
    displayName: "Jakarta NoSQL"
  },
  jenkins+: {
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList)
  }
}
