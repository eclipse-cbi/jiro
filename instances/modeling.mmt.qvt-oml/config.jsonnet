{
  project+: {
    fullName: "modeling.mmt.qvt-oml",
    displayName: "Eclipse QVT Operational"
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "gerrit-trigger",
    ],
  },
  seLinuxLevel: "s0:c51,c50",
}
