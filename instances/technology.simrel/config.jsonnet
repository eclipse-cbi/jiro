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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c53,c27",
}
