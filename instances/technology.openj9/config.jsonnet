local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.openj9",
    shortName: "openj9",
    displayName: "Eclipse OpenJ9",
  },
  jenkins+: {
    staticAgentCount: 50,
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect"])
  },
}
