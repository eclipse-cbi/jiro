{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
    resourcePacks: 5,
  },
  jenkins+: {
    version: "2.452.1-jdk17",
    staticAgentCount: 3,
    plugins+: [
      "basic-branch-build-strategies",
      "cloudbees-jenkins-advisor",
      "cloudbees-disk-usage-simple",
      "embeddable-build-status",
      "favorite",
      "gradle",
      "handy-uri-templates-2-api",
      "hashicorp-vault-plugin",
      "htmlpublisher",
      "jenkins-design-language",
      "mail-watcher-plugin",
      "mask-passwords",
      "metrics",
      "nexus-jenkins-plugin",
      "pipeline-graph-view",
      "pubsub-light",
      "slack",
      "sse-gateway",
      "trilead-api",
    ],
  },
  kubernetes+: {
    master+: {
      defaultJnlpAgentLabel: "basic-ubuntu",
    }
  },
  gradle+: {
    generate: true,
  },
}