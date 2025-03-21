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
        "jipp-ubuntu-2404-agent-6gb": currentCloud.templates["ubuntu-2404"] {
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
        "jipp-ubuntu-2404-agent-8gb": currentCloud.templates["ubuntu-2404"] {
          labels: ["centos-8-8gb", "centos-latest-8gb"],
          kubernetes+: {
            resources+: {
              memory: {
                limit: "8192Mi",
                request: "8192Mi",
              },
            },
          },
        },
        "jipp-ubuntu-2404-agent-4cpu": currentCloud.templates["ubuntu-2404"] {
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
  seLinuxLevel: "s0:c51,c35",
}
