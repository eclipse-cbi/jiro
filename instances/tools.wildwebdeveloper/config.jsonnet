local default = import '../../templates/default.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

default+ {
  project+: {
    fullName: "tools.wildwebdeveloper",
    shortName: "wildwebdeveloper",
    displayName: "Eclipse Wild Web Developer"
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
