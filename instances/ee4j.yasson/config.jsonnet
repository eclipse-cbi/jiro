{
  project+: {
    fullName: "ee4j.yasson",
    displayName: "Eclipse Yasson",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
  },
}
