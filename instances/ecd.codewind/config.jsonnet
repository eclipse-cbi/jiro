{
  project+: {
    fullName: "ecd.codewind",
    displayName: "Eclipse Codewind",
    resourcePacks: 3,
  },
  jenkins+: {
    staticAgentCount: 1,
    plugins+: [
      "basic-branch-build-strategies",
      "embeddable-build-status",
      "golang",
      "nodejs",
      "pipeline-github",
      "htmlpublisher",
    ],
  },
}
