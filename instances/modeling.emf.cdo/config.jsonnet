{
  project+: {
    fullName: "modeling.emf.cdo",
    displayName: "Eclipse CDO Model Repository",
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "mail-watcher-plugin",
      "pipeline-utility-steps",
      "zentimestamp",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c31,c30",
}
