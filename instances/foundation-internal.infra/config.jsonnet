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
    version: "2.414.2",
    staticAgentCount: 1,
    permissions: [
      {
        user: "anonymous",
        permissions: [
          "Overall/Read",
          "Job/Discover", // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1157#note_1153239
        ]
      },
      {
        group: "admins",
        permissions: ["Overall/Administer"],
      },
      {
        group: "foundation-internal.webdev",
        permissions: ["Overall/Read"],
      },
      {
        user: "wayne.beaton@eclipse-foundation.org",
        permissions: ["Overall/Read", "Agent/Build"],
      },
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/617
      {
        user: "boris.baldassari@eclipse-foundation.org",
        permissions: ["Overall/Read", "Agent/Build"],
      },
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/1033
      {
        user: "florent.zara@eclipse-foundation.org",
        permissions: ["Overall/Read", "Agent/Build"],
      },
      // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/issues/933
      {
        user: "shawn.kilpatrick@eclipse-foundation.org",
        permissions: ["Overall/Read", "Agent/Build"],
      },
      {
        user: "marco.jahn@eclipse-foundation.org",
        permissions: ["Overall/Read", "Agent/Build"],
      },
      {
        user: "mariateresa.delgado@eclipse-foundation.org",
        permissions: ["Overall/Read", "Agent/Build"],
      },
      {
        user: "rahul.mohangeetha@eclipse-foundation.org",
        permissions: ["Overall/Read", "Agent/Build"],
      },
      {
        user: "foundation-internal.it",
        permissions: permissionsTemplates.committerPermissionsList,
      }
    ],
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
