{
  project+: {
    fullName: "ee4j.glassfish",
    displayName: "Eclipse Glassfish",
    resourcePacks: 17
  },
  jenkins+: {
    agentConnectionTimeout: 300,
    theme: "quicksilver-light",
    plugins+: [
      "copyartifact",
      "view-job-filters",
      "gradle",
      "envinject",
    ],
  },
  seLinuxLevel: "s0:c40,c35",
  storage: {
    quota: "250Gi",
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  },
  develocity+: {
    generate: true,
  }
}
