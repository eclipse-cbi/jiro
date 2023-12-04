local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "foundation-internal.infra",
    displayName: "Eclipse Foundation Infra",
    resourcePacks: 2,
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/" + $.project.shortName,
  },
  jenkins+: {
    version: "2.426.1",
    staticAgentCount: 1,
    permissions:
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1157#note_1153239
      permissionsTemplates.user("anonymous", ["Overall/Read", "Job/Discover"]) +
      permissionsTemplates.group("admins", ["Overall/Administer"]) +
      permissionsTemplates.group("foundation-internal.webdev", ["Overall/Read"]) +
      permissionsTemplates.user("wayne.beaton@eclipse-foundation.org", ["Overall/Read", "Agent/Build"]) +
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/617
      permissionsTemplates.user("boris.baldassari@eclipse-foundation.org", ["Overall/Read", "Agent/Build"]) +
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1033
      permissionsTemplates.user("florent.zara@eclipse-foundation.org", ["Overall/Read", "Agent/Build"]) +
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/933
      permissionsTemplates.user("shawn.kilpatrick@eclipse-foundation.org", ["Overall/Read", "Agent/Build"]) +
      permissionsTemplates.user("marco.jahn@eclipse-foundation.org", ["Overall/Read", "Agent/Build"]) +
      permissionsTemplates.user("mariateresa.delgado@eclipse-foundation.org", ["Overall/Read", "Agent/Build"]) +
      permissionsTemplates.user("rahul.mohangeetha@eclipse-foundation.org", ["Overall/Read", "Agent/Build"]) +
      permissionsTemplates.group("foundation-internal.it", permissionsTemplates.committerPermissionsList)
    ,
    plugins+: [
      "docker-workflow",
      "kubernetes-cli",
      "mail-watcher-plugin",
      "pipeline-github",
      "slack",
      "gradle",
    ],
  },
  kubernetes+: {
    master+: {
      namespace: "foundation-internal-infra"
    }
  },
}
