{
  project+: {
    fullName: "technology.ease",
    displayName: "Eclipse Advanced Scripting Environment (EASE)"
  },
  jenkins+: {
    plugins+: [
      "blueocean",
      "code-coverage-api",
      "compact-columns",
      "copyartifact",
      "embeddable-build-status",
      "sectioned-view",
      "view-job-filters",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c35,c15",
}
