{
  project+: {
    fullName: "ee4j.jakartaee-platform",
    displayName: "Jakarta EE Platform",
  },
  jenkins+: {
    theme: "quicksilver-light"
  },
  maven+: {
    showVersion: false,
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c42,c29",
}
