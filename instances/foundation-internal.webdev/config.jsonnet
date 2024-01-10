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
    version: "2.426.1",
    staticAgentCount: 8, // fake higher number of staticAgent to increase controller's resources
    permissions+:
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1056
      permissionsTemplates.user("anonymous", ["Overall/Read", "Job/Discover"]) +
      permissionsTemplates.group($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger",]) +
      permissionsTemplates.group("admins", ["Overall/Administer"])
    ,
    plugins+: [
      "disable-failed-job",
      "docker-workflow",
      "kubernetes-cli",
      "mail-watcher-plugin",
      "openshift-client",
      "pipeline-github",
      "pipeline-graph-view",
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
