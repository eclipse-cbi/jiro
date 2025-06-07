{
  project+: {
    fullName: "modeling.viatra",
    displayName: "Eclipse VIATRA",
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "jipp-ubuntu-2404-6gb": currentCloud.templates["ubuntu-2404"] {
          labels: ["centos7-6gb"],
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
  seLinuxLevel: "s0:c56,c40",
}
