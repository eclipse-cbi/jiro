{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    version: "2.289.3",
    staticAgentCount: 3,
    plugins+: [
      "basic-branch-build-strategies",
      "cloudbees-jenkins-advisor",
      "cloudbees-disk-usage-simple",
      "embeddable-build-status",
      "favorite",
      "gradle",
      "handy-uri-templates-2-api",
      "htmlpublisher",
      "icon-shim",
      "jenkins-design-language",
      "mail-watcher-plugin",
      "mask-passwords",
      "metrics",
      "prometheus",
      "pubsub-light",
      "slack",
      "sse-gateway",
      "trilead-api",
    ],
  },
  gradle+: {
    generate: true,
  },
  deployment+: {
    cluster: "okd-c1"
  },
}