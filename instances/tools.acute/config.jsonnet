{
  project+: {
    fullName: "tools.acute",
    displayName: "Eclipse aCute"
  },
  jenkins+: {
    plugins+: [
      "envinject",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
