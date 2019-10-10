local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ecd.codewind",
    shortName: "codewind",
    displayName: "Eclipse Codewind",
    sponsorshipLevel: "S2",
    resourcePacks: 3,
  },
  jenkins+: {
    staticAgentCount: 1
  },
}
