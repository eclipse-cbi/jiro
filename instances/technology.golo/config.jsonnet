local default = import '../../templates/default.libsonnet';

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
