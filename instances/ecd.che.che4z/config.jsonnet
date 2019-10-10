local default = import '../../templates/default.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

default+ {
  project+: {
    fullName: "ecd.che.che4z",
    shortName: "che4z",
    displayName: "Eclipse Che4z"
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
