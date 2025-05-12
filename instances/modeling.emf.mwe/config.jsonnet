{
  project+: {
    fullName: "modeling.emf.mwe",
    displayName: "Eclipse Modeling Workflow Engine"
  },
  jenkins+: {
    plugins+: [
      "parameterized-scheduler",
      "matrix-communication",
    ],
  },
  seLinuxLevel: "s0:c48,c47",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
