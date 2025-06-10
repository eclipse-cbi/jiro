{
  project+: {
    fullName: "ee4j.openmq",
    displayName: "Eclipse OpenMQ",
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
