{
  project+: {
    fullName: "iot.keypop",
    displayName: "Eclipse Keypop",
  },
  jenkins+: {
    plugins+: [
      "gradle",
    ],
  },
  gradle+: {
    generate: true,
  }
}
