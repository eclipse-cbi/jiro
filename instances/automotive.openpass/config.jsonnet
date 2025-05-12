{
  project+: {
    fullName: "automotive.openpass",
    displayName: "Eclipse openPASS",
    resourcePacks: 13
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
      "nodejs",
      "conditional-buildstep",
    ],
  },
  seLinuxLevel: "s0:c54,c4",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
