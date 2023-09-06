{
  project+: {
    fullName: "iot.keypop",
    displayName: "Eclipse Keypop",
  },
  jenkins+: {
    "version": "2.387.3",
    plugins+: [
      "gradle",
    ],
  },
  gradle+: {
    generate: true,
  }
}
