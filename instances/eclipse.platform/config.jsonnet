{
  project+: {
    fullName: "eclipse.platform",
    displayName: "Eclipse Platform",
    resourcePacks: 4,
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "pipeline-github",
    ],
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "jipp-centos-7-agent-6gb": currentCloud.templates["centos-7"] {
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
