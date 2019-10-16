local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.cbi",
    shortName: "cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    version: "2.190.1",
    staticAgentCount: 3,
  }
}