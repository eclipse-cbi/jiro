local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "eclipse.jdt.ls",
    shortName: "ls",
    displayName: "Eclipse JDT Language Server"
  },
  jenkins+: {
    permissions+: [
      {
        principal: "eclipse.jdt.jdtls",
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ]
  }
}
