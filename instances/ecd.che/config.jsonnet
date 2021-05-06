{
  project+: {
    fullName: "ecd.che",
    displayName: "Eclipse Che"
  },
  deployment+: {
    cluster: "okd-c1"
  },
  jenkins+: {
    plugins+: [
      "job-dsl",
      "purge-build-queue-plugin",
    ],
  },
}
