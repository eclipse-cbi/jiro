{
  project+: {
    fullName: "ecd.cdt-cloud",
    displayName: "Eclipse CDT.cloud",
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
      "mail-watcher-plugin",
      "pipeline-utility-steps",
    ],
  },
}
