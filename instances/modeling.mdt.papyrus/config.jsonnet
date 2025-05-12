{
  project+: {
    fullName: "modeling.mdt.papyrus",
    displayName: "Eclipse Papyrus",
    resourcePacks: 3, //https://bugs.eclipse.org/bugs/show_bug.cgi?id=570916
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
      "nodejs",
      "zentimestamp",
    ],
  },
  clouds+: {
    kubernetes+: {
      local currentCloud = self,
      templates+: {
        "ubuntu-2404-agent-6gb": currentCloud.templates["ubuntu-2404"] {
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
  seLinuxLevel: "s0:c51,c10",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}