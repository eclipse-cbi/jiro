{
  project+: {
    fullName: "modeling.mwe",
    displayName: "Eclipse Modeling Workflow Engine"
  },
  jenkins+: {
    plugins+: [
      "parameterized-scheduler",
      "matrix-communication",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c48,c47",
}
