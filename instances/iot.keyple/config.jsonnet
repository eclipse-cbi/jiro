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
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=552742
        principal: "brice.ruppen@armotic.fr",
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ]
  }
}
