{
  project+: {
    fullName: "technology.ceylon",
    displayName: "Eclipse Ceylon",
  },
  jenkins+: {
    plugins+: [
      "nodejs",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
