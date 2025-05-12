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
  seLinuxLevel: "s0:c31,c30",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
