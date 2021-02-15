local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "rt.ecf",
    displayName: "Eclipse Communication Framework"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    permissions+: [
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=546758
        principal: "mat.booth@redhat.com", 
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ],
    plugins+: [
      "envinject",
    ],
  }
}
