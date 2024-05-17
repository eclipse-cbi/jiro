{
  project+: {
    fullName: "modeling.hawk",
    displayName: "Eclipse Hawk"
  },
  jenkins+: {
    plugins+: [
      "lockable-resources",
      "slack",
    ],
  },
}
