{
  project+: {
    fullName: "ecd.theia",
    displayName: "Eclipse Theia",
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
      "pipeline-utility-steps",
    ],
  },
}
