{
  project+: {
    fullName: "eclipse.equinox",
    displayName: "Eclipse Equinox"
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
    ],
  },
  deployment+: {
    cluster: "okd-c1",
  },
}
