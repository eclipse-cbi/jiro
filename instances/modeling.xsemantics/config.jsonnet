{
  project+: {
    fullName: "modeling.xsemantics",
    displayName: "Eclipse Xsemantics",
  },
  jenkins+: {
    plugins+: [
      "mail-watcher-plugin",
    ],
  },
  deployment+: {
    cluster: "okd-c1"
  },
}
