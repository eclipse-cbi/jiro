local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ee4j.mail",
    displayName: "Jakarta Mail",
  },
  jenkins+: {
    theme: "quicksilver-light",
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
    plugins+: [
      "copyartifact",
    ],
  }
}
