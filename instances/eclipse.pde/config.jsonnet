{
  project+: {
    fullName: "eclipse.pde",
    displayName: "Eclipse Plugin Development Environment (PDE)",
    resourcePacks: 3,
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
      },
    },
  },
  seLinuxLevel: "s0:c51,c25",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}
