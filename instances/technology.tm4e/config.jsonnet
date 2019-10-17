local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.tm4e",
    shortName: "tm4e",
    displayName: "Eclipse TM4E"
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
