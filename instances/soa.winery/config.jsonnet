{
  project+: {
    fullName: "soa.winery",
    displayName: "Eclipse Winery",
  },
  jenkins+: {
    plugins+: [
      "nodejs",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
