{
  project+: {
    fullName: "eclipse.platform",
    displayName: "Eclipse Platform",
    resourcePacks: 4,
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
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
        "jipp-centos-8-agent-4cpu": currentCloud.templates["centos-8"] {
          labels: ["centos-8-4cpu"],
          kubernetes+: {
            resources+: {
              cpu: {
                limit: "4000m",
                request: "4000m",
              },
            },
          },
        },
      },
    },
  },
}
