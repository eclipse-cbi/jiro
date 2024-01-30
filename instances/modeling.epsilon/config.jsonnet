{
  project+: {
    fullName: "modeling.epsilon",
    displayName: "Eclipse Epsilon"
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
      "slack",
      "lockable-resources",
    ],
  },
}
