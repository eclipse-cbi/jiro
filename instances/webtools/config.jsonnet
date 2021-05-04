local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "webtools",
    displayName: "Eclipse Web Tools Platform Project",
  },
  jenkins+: {
    permissions+:
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=568553#c23
      permissionsTemplates.projectPermissions("nboldt@redhat.com", permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"]),
    plugins+: [
      "ansicolor",
      "dashboard-view",
      "description-setter",
      "log-parser",
      "show-build-parameters",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  }
}
