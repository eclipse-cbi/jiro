local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "adoptium.emt4j",
    displayName: "Eclipse Migration Toolkit for Java",
  },
  jenkins+: {
    // workaround to avoid errors, when the Gerrit plugin is disabled
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
  }
}
