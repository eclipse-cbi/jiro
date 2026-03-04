{
  project+: {
    fullName: "ee4j.openmq",
    displayName: "Eclipse OpenMQ",
    centralTesting: true,
  },
  jenkins+: {
    plugins+: [
      "github-scm-trait-notification-context",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c50,c15",
}
