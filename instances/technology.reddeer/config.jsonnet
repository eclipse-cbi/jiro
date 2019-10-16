local default = import '../../templates/config.libsonnet';

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
