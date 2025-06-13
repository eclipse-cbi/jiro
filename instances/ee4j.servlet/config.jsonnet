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
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c53,c12",
}
