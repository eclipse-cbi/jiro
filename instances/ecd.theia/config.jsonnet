{
  project+: {
    fullName: "ecd.theia",
    displayName: "Eclipse Theia",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
      "embeddable-build-status",
      "mail-watcher-plugin",
      "nodejs",
      "pipeline-utility-steps",
    ],
  },
  seLinuxLevel: "s0:c55,c25",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
