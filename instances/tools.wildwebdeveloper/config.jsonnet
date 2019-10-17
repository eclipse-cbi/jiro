local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "tools.wildwebdeveloper",
    shortName: "wildwebdeveloper",
    displayName: "Eclipse Wild Web Developer"
  },
    jenkins+: {
    permissions: [
      {
        grantedPermissions:
          if perm.principal == $.project.unixGroupName then
            permissionsTemplates.projectPermissions
          else
            perm.grantedPermissions,
        principal: perm.principal
      } for perm in super.permissions
    ]
  }
}
