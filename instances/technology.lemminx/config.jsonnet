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
}
