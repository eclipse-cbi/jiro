local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.xwt",
    displayName: "Eclipse XWT"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ],
    permissions+: [
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=547567
        principal: "patrick.tessier@cea.fr",
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ]
  }
}
