{
  project+: {
    fullName: "eclipse.e4",
    displayName: "Eclipse e4",
  },
  jenkins+: {
    plugins+: [
      "gerrit-code-review",
    ],
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
}
