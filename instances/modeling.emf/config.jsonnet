{
  project+: {
    fullName: "modeling.emf",
    displayName: "Eclipse Modeling Framework",
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
      "multiple-scms",
      "zentimestamp",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c38,c7",
}
