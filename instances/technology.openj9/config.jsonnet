local default = import '../../templates/config.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

default+ {
  project+: {
    fullName: "technology.openj9",
    shortName: "openj9",
    displayName: "Eclipse OpenJ9",
    sponsorshipLevel: "SP2",
    
  },
  jenkins+: {
    staticAgentCount: 50,
    permissions: [
      {
        grantedPermissions:
          if perm.principal == $.project.fullName then
            std.sort(permissionsTemplates.projectPermissions + ["Agent/Connect", "Agent/Disconnect"])
          else
            perm.grantedPermissions,
        principal: perm.principal
      } for perm in super.permissions
    ]
  },
}
