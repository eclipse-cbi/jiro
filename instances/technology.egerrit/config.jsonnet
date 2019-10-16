local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.egerrit",
    shortName: "egerrit",
    displayName: "Eclipse EGerrit"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  },
  jenkins+: {
    staticAgentCount: 1,
  },
}
