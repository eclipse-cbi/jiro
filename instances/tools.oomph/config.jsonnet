{
  project+: {
    fullName: "tools.oomph",
    displayName: "Eclipse Oomph",
    resourcePacks: 4
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "mail-watcher-plugin",
      "multiple-scms",
      "zentimestamp",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  clouds+: {
    kubernetes+: { 
      local currentCloud = self,
      templates+: {
        "jipp-basic-agent-16gb": currentCloud.templates["basic"] {
          labels: ["basic-16gb"],
          kubernetes+: {
            resources+: {
              cpu: {
                limit: "4000m",
                request: "4000m",
              },
              memory: {
                limit: "16384Mi",
                request: "16384Mi",
              },
            },
          },
        },
      },
    },
  },
}
