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
    permissions+:
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=547567
      permissionsTemplates.user("patrick.tessier@cea.fr", permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"])
  },
  seLinuxLevel: "s0:c57,c49",
}
