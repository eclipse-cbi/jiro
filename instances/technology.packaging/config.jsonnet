local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.packaging",
    displayName: "Eclipse Packaging Project",
  },
  jenkins+: {
    permissions+:
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2481
      permissionsTemplates.user("ed.merks@gmail.com", ["Overall/Read", "Job/Build", "Job/Read", "Job/ExtendedRead", "Job/Cancel", "Agent/Build"]) +
      permissionsTemplates.user("packaging-trigger-bot@eclipse.org", ["Overall/Read", "Job/Read", "Job/Build", "Agent/Build"]), // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/6174
    plugins+: [
      "urltrigger",
      "parameterized-remote-trigger-plugin",
      "pipeline-graph-view",
    ]
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c51,c0",
}
