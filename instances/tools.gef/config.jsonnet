{
  project+: {
    fullName: "tools.gef",
    displayName: "Eclipse GEF",
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "copyartifact",
      "parameterized-scheduler",
      "slack",
      "github-checks",
      "git-forensics",
    ],
  },
  seLinuxLevel: "s0:c40,c0",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
