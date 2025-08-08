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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c46,c40",
}
