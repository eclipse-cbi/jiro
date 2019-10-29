local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "polarsys.polarsys.time4sys",
    shortName: "time4sys",
    displayName: "Eclipse Time4Sys"
  },
  jenkins+: {
    permissions+: [
      {
        principal: "polarsys.time4sys",
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ]
  }
}
