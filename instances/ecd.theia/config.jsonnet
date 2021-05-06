{
  project+: {
    fullName: "ecd.theia",
    displayName: "Eclipse Theia",
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
      "pipeline-utility-steps",
    ],
  },
}
