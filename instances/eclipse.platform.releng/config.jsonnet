local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "eclipse.platform.releng",
    shortName: "releng",
    displayName: "Eclipse Platform Releng",
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  },
  jenkins+: {
    permissions+: [
      {
        principal: "eclipse.platform",
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
      }
    ]
  }
}
