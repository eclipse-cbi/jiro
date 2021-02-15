{
  project+: {
    fullName: "tools.datatools",
    displayName: "Eclipse Data Tools Platform",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
      "description-setter",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
