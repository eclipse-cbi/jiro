{
  project+: {
    fullName: "technology.scout",
    displayName: "Eclipse Scout",
  },
  jenkins+: {
    plugins+: [
      "job-dsl",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
