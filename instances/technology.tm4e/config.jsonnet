local default = import '../../templates/config.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

default+ {
  project+: {
    fullName: "technology.tm4e",
    shortName: "tm4e",
    displayName: "Eclipse TM4E"
  },
    jenkins+: {
    permissions: [
      {
        grantedPermissions:
          if perm.principal == $.project.fullName then
            permissionsTemplates.projectPermissions
          else
            perm.grantedPermissions,
        principal: perm.principal
      } for perm in super.permissions
    ]
  }
}
