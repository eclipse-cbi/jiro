{
  project+: {
    fullName: "rt.rap",
    displayName: "Eclipse RAP",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c52,c9",
}
