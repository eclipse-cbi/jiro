{
  project+: {
    fullName: "polarsys.kitalpha",
    displayName: "Eclipse Kitalpha",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  clouds+: {
    kubernetes+: { 
      local currentCloud = self,
      templates+: {
        "jipp-ubuntu-2404-agent-6gb": currentCloud.templates["ubuntu-2404"] {
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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c46,c5",
}
