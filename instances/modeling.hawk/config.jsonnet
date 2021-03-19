{
  project+: {
    fullName: "modeling.hawk",
    displayName: "Eclipse Hawk"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  jenkins+: {
    plugins+: [
      "slack",
    ],
  },
}
