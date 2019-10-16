local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.golo",
    shortName: "golo",
    displayName: "Eclipse Golo"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
