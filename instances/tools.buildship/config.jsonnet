{
  project+: {
    fullName: "tools.buildship",
    displayName: "Eclipse Buildship",
  },  
  jenkins+: {
    plugins+: [
      "envinject",
      "gradle",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c64,c39",
}
