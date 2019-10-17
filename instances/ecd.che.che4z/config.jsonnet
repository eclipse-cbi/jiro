local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ecd.che.che4z",
    shortName: "che4z",
    displayName: "Eclipse Che4z"
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
