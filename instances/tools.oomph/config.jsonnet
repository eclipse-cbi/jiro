{
  project+: {
    fullName: "tools.oomph",
    displayName: "Eclipse Oomph",
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "mail-watcher-plugin",
      "multiple-scms",
      "zentimestamp",
    ],
  },
  deployment+: {
    host: "ci-staging.eclipse.org",
    cluster: "okd-c1",
  }
}
