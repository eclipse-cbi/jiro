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
}
