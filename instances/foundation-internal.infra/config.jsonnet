{
  project+: {
    fullName: "foundation-internal.infra",
    displayName: "Eclipse Foundation Infra"
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/" + $.project.shortName
  },
  jenkins+: {
    version: "2.263.2-jdk11",
    staticAgentCount: 1,
    permissions: [
      {
        principal: "admins",
        grantedPermissions: [
          "Overall/Administer"
        ]
      }
    ]
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
