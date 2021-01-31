{
  project+: {
    fullName: "ee4j.wasp",
    displayName: "Eclipse WaSP",
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
