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
        user: "patrick.tessier@cea.fr",
        permissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ]
  }
}
