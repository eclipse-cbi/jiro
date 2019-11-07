local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "iot.keyple",
    shortName: "keyple",
    displayName: "Eclipse Keyple",
  },
  jenkins+: {
    permissions+: [
      {
        principal: "brice.ruppen@armotic.fr",
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ]
  }
}
