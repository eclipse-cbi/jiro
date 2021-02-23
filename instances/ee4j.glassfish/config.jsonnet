local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ee4j.glassfish",
    displayName: "Eclipse Glassfish",
    resourcePacks: 16
  },
  jenkins+: {
    agentConnectionTimeout: 300,
    theme: "quicksilver-light",
    // workaround to avoid errors, when the Gerrit plugin is disabled
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
    plugins+: [
      "copyartifact",
      "view-job-filters",
    ],
  }
}
