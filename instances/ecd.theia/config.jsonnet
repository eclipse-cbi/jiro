{
  project+: {
    fullName: "ecd.theia",
    displayName: "Eclipse Theia",
  },
  jenkins+: {
    plugins+: [
      "embeddable-build-status",
      "mail-watcher-plugin",
      "nodejs",
      "pipeline-utility-steps",
    ],
  },
  seLinuxLevel: "s0:c55,c25",
}
