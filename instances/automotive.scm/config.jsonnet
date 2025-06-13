{
  project+: {
    fullName: "automotive.scm",
    displayName: "Eclipse SCM",
    resourcePacks: 3
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c38,c22",
}
