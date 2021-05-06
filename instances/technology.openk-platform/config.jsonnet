{
  project+: {
    fullName: "technology.openk-platform",
    displayName: "Eclipse openK platform"
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
}
