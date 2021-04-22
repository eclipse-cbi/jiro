{
  project+: {
    fullName: "technology.lemminx",
    displayName: "Eclipse LemMinX",
  },
  jenkins+: {
    plugins+: [
      "blueocean",
      "embeddable-build-status",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
