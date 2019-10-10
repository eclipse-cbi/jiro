local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.reddeer",
    shortName: "reddeer",
    displayName: "Eclipse RedDeer"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  },
  jenkins+: {
    staticAgentCount: 1,
  },
}
