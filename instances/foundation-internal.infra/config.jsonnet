{
  project+: {
    fullName: "foundation-internal.infra",
    displayName: "Eclipse Foundation Infra"
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/" + $.project.shortName,
    cluster: "okd-c1"
  },
  jenkins+: {
    version: "2.263.3",
    staticAgentCount: 1,
    permissions: [
      {
        principal: "admins",
        grantedPermissions: [
          "Overall/Administer"
        ]
      }
    ],
    plugins+: [
      "docker-workflow",
      "kubernetes-cli",
      "slack",
    ],
  },
  kubernetes+: {
    master+: {
      namespace: "foundation-internal-infra"
    }
  },
  secrets+: {
    "gerrit-trigger-plugin": {},
  },
}
