{
  project+: {
    fullName: "modeling.mmt.qvtd",
    displayName: "Eclipse QVTd"
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c52,c4",
}
