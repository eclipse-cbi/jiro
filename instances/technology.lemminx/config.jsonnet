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
  seLinuxLevel: "s0:c46,c25",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
