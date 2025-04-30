{
  project+: {
    fullName: "tools.linuxtools",
    displayName: "Eclipse Linux Tools"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
      "build-with-parameters"
    ],
  },
  seLinuxLevel: "s0:c46,c40",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}
