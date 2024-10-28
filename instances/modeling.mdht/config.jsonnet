{
  project+: {
    fullName: "modeling.mdht",
    displayName: "Eclipse Model Driven Health Tools"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c47,c39",
}
