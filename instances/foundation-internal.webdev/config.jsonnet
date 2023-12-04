local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "foundation-internal.webdev",
    displayName: "Eclipse Foundation WebDev",
    resourcePacks: 10,
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/"+ $.project.shortName,
  },
  jenkins+: {
    version: "2.414.2",
    staticAgentCount: 8, // fake higher number of staticAgent to increase controller's resources
    permissions: [
      {
        user: "anonymous",
        permissions: [
          "Overall/Read",
          "Job/Discover",  // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1056
        ]
      },
      {
        group: $.project.unixGroupName,
        permissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger",],
      },
      {
        group "admins",
        permissions: ["Overall/Administer"],
      },
    ],
    plugins+: [
      "disable-failed-job",
      "docker-workflow",
      "kubernetes-cli",
      "mail-watcher-plugin",
      "openshift-client",
      "pipeline-github",
      "slack",
    ],
  },
  kubernetes+: {
    master+: {
      namespace: "foundation-internal-webdev"
    }
  },
  secrets+: {
    "gerrit-trigger-plugin": {},
  },
}
