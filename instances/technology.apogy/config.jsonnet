{
  project+: {
    fullName: "technology.apogy",
    displayName: "Eclipse Apogy"
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
