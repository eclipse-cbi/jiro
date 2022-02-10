local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "rt.ecf",
    displayName: "Eclipse Communication Framework"
  },
  jenkins+: {
    permissions+: [
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=546758
        principal: "mat.booth@gmail.com", 
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ],
    plugins+: [
      "envinject",
    ],
  }
}
