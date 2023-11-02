{
  project+: {
    fullName: "eclipse.pde",
    displayName: "Eclipse Plugin Development Environment (PDE)"
  },
  jenkins+: {
    plugins+: [
      "github-checks",
      "git-forensics",
    ],
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "jipp-centos-8-agent-8gb": currentCloud.templates["centos-8"] {
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
      },
    },
  },
}
