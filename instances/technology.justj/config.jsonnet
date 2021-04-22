{
  project+: {
    fullName: "technology.justj",
    displayName: "Eclipse JustJ",
  },
  jenkins+: {
    plugins+: [
      "build-with-parameters",
      "mail-watcher-plugin",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
