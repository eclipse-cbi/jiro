{
  project+: {
    fullName: "modeling.xsemantics",
    displayName: "Eclipse Xsemantics",
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
    ],
  },
  seLinuxLevel: "s0:c57,c39",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
