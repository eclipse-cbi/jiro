{
  project+: {
    fullName: "ee4j.servlet",
    displayName: "Jakarta Servlet",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
  seLinuxLevel: "s0:c53,c12",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}
