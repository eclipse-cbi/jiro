local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.xwt",
    shortName: "xwt",
    displayName: "Eclipse XWT"
  },
  jenkins+: {
    permissions+: [
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=547567
        principal: "patrick.tessier@cea.fr", 
        grantedPermissions: permissionsTemplates.projectPermissionsWithGerrit
      }
    ]
  }
}
