{
  project+: {
    fullName: "technology.birt",
    displayName: "Eclipse Business Intelligence and Reporting Tools (BIRT)",
  },
  jenkins+: {
    plugins+: [
      "extended-choice-parameter",
    ]
  },
  seLinuxLevel: "s0:c30,c20",
}
