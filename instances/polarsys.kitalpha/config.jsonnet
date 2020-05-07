{
  project+: {
    fullName: "polarsys.kitalpha",
    displayName: "Eclipse Kitalpha",
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  },
  clouds+: {
    "c1-ci"+: { 
      local currentCloud = self,
      templates+: {
        "jipp-migration-agent-6gb": currentCloud.templates["jipp-migration-agent"] {
          labels: ["migration-6gb"],
          kubernetes+: {
            resources+: {
              memory: {
                limit: "6144Mi",
                request: "6144Mi",
              },
            },
          },
        },
      },
    },
  },
}
