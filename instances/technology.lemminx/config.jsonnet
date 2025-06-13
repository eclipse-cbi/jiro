{
  project+: {
    fullName: "technology.lemminx",
    displayName: "Eclipse LemMinX",
  },
  jenkins+: {
    plugins+: [
      "blueocean",
      "embeddable-build-status",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c46,c25",
}
