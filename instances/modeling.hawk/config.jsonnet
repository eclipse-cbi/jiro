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
  seLinuxLevel: "s0:c41,c25",
}
