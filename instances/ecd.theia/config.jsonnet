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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c55,c25",
}
