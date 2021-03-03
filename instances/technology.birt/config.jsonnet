{
  project+: {
    fullName: "technology.birt",
    displayName: "Eclipse Business Intelligence and Reporting Tools (BIRT)",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "extended-choice-parameter",
    ]
  }
}
