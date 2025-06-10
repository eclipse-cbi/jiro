{
  project+: {
    fullName: "rt.ecf",
    displayName: "Eclipse Communication Framework"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c35,c25",
}
