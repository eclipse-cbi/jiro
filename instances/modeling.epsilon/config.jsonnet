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
  seLinuxLevel: "s0:c38,c37",
}
