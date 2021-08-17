local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.comma",
    displayName: "Eclipse CommaSuite",
  },
  jenkins+: {
    permissions:
      // workaround to avoid errors, when the Gerrit plugin is disabled
      permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
  },
}
