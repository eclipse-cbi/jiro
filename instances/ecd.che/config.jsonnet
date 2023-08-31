{
  project+: {
    fullName: "ecd.che",
    displayName: "Eclipse Che"
  },
  jenkins+: {
    version: "2.387.3",
    plugins+: [
      "job-dsl",
      "purge-build-queue-plugin",
      "gerrit-trigger",
    ],
  },
}
