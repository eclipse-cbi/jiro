{
  project+: {
    fullName: "technology.nebula.nattable",
    displayName: "Eclipse Nebula NatTable",
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c49,c14",
}
