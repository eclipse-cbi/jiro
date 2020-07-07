{
  project+: {
    fullName: "modeling.tmf.xtext",
    displayName: "Eclipse Xtext",
    resourcePacks: 2,
  },
  jenkins+: {
    staticAgentCount: 2,
  },
  gradle+: {
    generate: true,
  },
  clouds+: {
    kubernetes+: { 
      local currentCloud = self,
      templates+: {
        "centos-7-agent-6gb": currentCloud.templates["centos-7"] {
          labels: ["centos-7-6gb"],
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
