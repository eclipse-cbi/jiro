local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "ee4j.jakartaee-tck",
    displayName: "Eclipse Jakarta EE TCK",
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
}
