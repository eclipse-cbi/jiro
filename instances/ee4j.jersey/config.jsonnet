{
  project+: {
    fullName: "ee4j.jersey",
    displayName: "Eclipse Jersey",
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  }
}
