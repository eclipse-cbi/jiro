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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c54,c4",
}
