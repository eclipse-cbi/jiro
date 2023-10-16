{
  project+: {
    fullName: "modeling.sirius",
    displayName: "Eclipse Sirius",
    resourcePacks: 2,
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "zentimestamp",
    ],
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "centos-7-6gb": currentCloud.templates["centos-7"] {
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
