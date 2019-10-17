local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ee4j.nosql",
    shortName: "nosql",
    displayName: "Jakarta NoSQL"
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
