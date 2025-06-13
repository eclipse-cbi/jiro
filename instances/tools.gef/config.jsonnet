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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c40,c0",
}
