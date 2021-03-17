{
  project+: {
    fullName: "modeling.epsilon",
    displayName: "Eclipse Epsilon"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "slack",
      "embeddable-build-status",
    ],
  },
}
