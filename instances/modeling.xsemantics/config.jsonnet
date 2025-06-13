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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c57,c39",
}
