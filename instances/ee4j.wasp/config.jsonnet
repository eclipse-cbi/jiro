{
  project+: {
    fullName: "ee4j.wasp",
    displayName: "Eclipse WaSP",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
