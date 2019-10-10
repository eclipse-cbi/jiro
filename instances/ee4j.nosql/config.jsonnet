local default = import '../../templates/default.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.nosql",
    shortName: "nosql",
    displayName: "Jakarta NoSQL"
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
