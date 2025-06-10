{
  project+: {
    fullName: "eclipse.equinox",
    displayName: "Eclipse Equinox",
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c39,c4",
}
