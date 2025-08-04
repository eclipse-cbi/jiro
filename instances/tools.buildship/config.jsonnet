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
  develocity+: {
    generate: true,
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c64,c39",
}
