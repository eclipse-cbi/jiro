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
    staticAgentCount: 8, // fake higher number of staticAgent to increase controller's resources
    permissions+:
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1056
      permissionsTemplates.user("anonymous", ["Overall/Read", "Job/Discover"]) +
      permissionsTemplates.group("admins", ["Overall/Administer"]) +
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1571#note_1985722
      permissionsTemplates.user("martin.lowe@eclipse-foundation.org", ["Credentials/Create", "Credentials/Update"])
    ,
    plugins+: [
      "disable-failed-job",
      "docker-workflow",
      "gradle",
      "hashicorp-vault-plugin",
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
  develocity+: {
    generate: true,
  },
  secrets+: {
    "gerrit-trigger-plugin": {},
  },
  seLinuxLevel: "s0:c28,c2",
}
