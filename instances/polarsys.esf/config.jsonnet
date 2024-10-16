{
  project+: {
    fullName: "polarsys.esf",
    displayName: "Eclipse Safety Framework"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c39,c19",
}
