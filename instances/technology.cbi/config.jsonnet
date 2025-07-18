{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
    resourcePacks: 5,
  },
  jenkins+: {
    version: "2.504.3",
    staticAgentCount: 3,
    plugins+: [
      "basic-branch-build-strategies",
      "cloudbees-jenkins-advisor",
      "cloudbees-disk-usage-simple",
      "declarative-pipeline-migration-assistant",
      "docker-workflow",
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
      "minio",
      "nexus-jenkins-plugin",
      "pubsub-light",
      "slack",
      "sse-gateway",
      "trilead-api",
    ],
  },
  gradle+: {
    generate: true,
  },
  develocity+: {
    generate: true,
  },
  seLinuxLevel: "s0:c27,c9",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}