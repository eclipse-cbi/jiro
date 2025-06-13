{
  project+: {
    fullName: "ecd.glsp",
    displayName: "Eclipse GLSP",
  },
  jenkins+: {
    plugins+: [
      "github-checks",
      "embeddable-build-status",
      "htmlpublisher",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c41,c0",
}
