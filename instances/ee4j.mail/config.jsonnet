local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ee4j.mail",
    displayName: "Jakarta Mail",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    theme: "quicksilver-light",
    // workaround to avoid errors, when the Gerrit plugin is disabled
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
    plugins+: [
      "copyartifact",
    ],
  }
}
