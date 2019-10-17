local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.openj9",
    shortName: "openj9",
    displayName: "Eclipse OpenJ9",
  },
  jenkins+: {
    staticAgentCount: 50,
    permissions: [
      {
        grantedPermissions:
          if perm.principal == $.project.unixGroupName then
            std.sort(permissionsTemplates.projectPermissions + ["Agent/Connect", "Agent/Disconnect"])
          else
            perm.grantedPermissions,
        principal: perm.principal
      } for perm in super.permissions
    ]
  },
}
