{
  project+: {
    fullName: "polarsys.kitalpha",
    displayName: "Eclipse Kitalpha",
  },
  clouds+: {
    kubernetes+: { 
      local currentCloud = self,
      templates+: {
        "jipp-migration-agent-6gb": currentCloud.templates["centos-7"] {
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
