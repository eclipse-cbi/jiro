{
  project+: {
    fullName: "modeling.edapt",
    displayName: "Eclipse Edapt",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c36,c15",
}
