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
  clouds+: {
    kubernetes+: { 
      local currentCloud = self,
      templates+: {
        "jipp-basic-agent-8gb": currentCloud.templates["basic"] {
          labels: ["basic-8gb"],
          kubernetes+: {
            resources+: {
              cpu: {
                limit: "2000m",
                request: "2000m",
              },
              memory: {
                limit: "8192Mi",
                request: "8192Mi",
              },
            },
          },
        },
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
