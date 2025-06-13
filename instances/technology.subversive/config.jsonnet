{
  project+: {
    fullName: "technology.subversive",
    displayName: "Eclipse Subversive",
  },
  jenkins+: {
    plugins+: [
      "subversion",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c55,c0",
}
