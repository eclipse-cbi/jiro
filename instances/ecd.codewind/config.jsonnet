{
  project+: {
    fullName: "ecd.codewind",
    displayName: "Eclipse Codewind",
    resourcePacks: 3,
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    staticAgentCount: 1,
    plugins+: [
      "basic-branch-build-strategies",
      "embeddable-build-status",
      "golang",
      "mail-watcher-plugin",
      "nodejs",
      "pipeline-github",
      "htmlpublisher",
    ],
  },
}
