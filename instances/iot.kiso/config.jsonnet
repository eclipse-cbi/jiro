{
  project+: {
    fullName: "iot.kiso",
    displayName: "Eclipse Kiso",
  },
  jenkins+: {
    plugins+: [
      "dashboard-view",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
