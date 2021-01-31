{
  project+: {
    fullName: "iot.ditto",
    displayName: "Eclipse Ditto",
  },
  jenkins+: {
    plugins+: [
      "nodejs",
      "pipeline-utility-steps",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
