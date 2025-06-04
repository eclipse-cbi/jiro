{
  project+: {
    fullName: "technology.simrel",
    displayName: "Eclipse SimRel",
  },
  jenkins+: {
    plugins+: [
      "build-blocker-plugin",
      "docker-workflow",
      "mail-watcher-plugin",
      "date-parameter",
      "lockable-resources"
    ],
  },
  seLinuxLevel: "s0:c53,c27",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}
