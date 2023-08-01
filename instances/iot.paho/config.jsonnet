{
  project+: {
    fullName: "iot.paho",
    displayName: "Eclipse Paho",
  },
  jenkins+: {
    plugins+: [
      "gradle",
      "gerrit-trigger",
    ],
  },
}
