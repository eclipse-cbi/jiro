{
  project+: {
    fullName: "ee4j.grizzly",
    displayName: "Eclipse Grizzly",
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
}
