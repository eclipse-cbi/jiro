{
  project+: {
    fullName: "tools.dartboard",
    displayName: "Eclipse Dartboard"
  },
  jenkins+: {
    plugins+: [
      "mask-passwords",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
