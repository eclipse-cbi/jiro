local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "eclipse.platform.releng",
    shortName: "releng",
    displayName: "Eclipse Platform Releng",
    resourcePacks: 4,
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  },
  jenkins+: {
    permissions+: 
      permissionsTemplates.projectPermissions("eclipse.platform", permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"]) +
      permissionsTemplates.projectPermissions("sravankumarl@in.ibm.com", ["Agent/Connect", "Agent/Disconnect"])
  }
}
