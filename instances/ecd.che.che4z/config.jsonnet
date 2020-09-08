local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "ecd.che.che4z",
    displayName: "Eclipse Che4z"
  },
  jenkins+: {
    permissions:
      permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=566607
      permissionsTemplates.projectPermissions("andrea.zaccaro@broadcom.com", ["Credentials/Create", "Credentials/Update"])
  }
}
