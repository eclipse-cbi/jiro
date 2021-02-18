{
  project+: {
    fullName: "iot.paho",
    displayName: "Eclipse Paho",
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ],
  },
}
