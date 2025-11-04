local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "ee4j.jakartaee-platform",
    displayName: "Jakarta EE Platform",
    resourcePacks: 52,
  },
  jenkins+: {
    maxConcurrency: 25,
    agentConnectionTimeout: 300,
    theme: "quicksilver-light",
    plugins+: [
      "blueocean",
      "copyartifact",
      "description-setter",
      "envinject",
      "extended-choice-parameter",
      "groovy",
    ],
    permissions+:
      permissionsTemplates.user("smarlow@redhat.com", ["Overall/SystemRead"]),
  },
  maven+: {
    showVersion: false,
  },
  storage: {
    quota: "250Gi",
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c42,c29",
}
