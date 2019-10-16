local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.collections",
    shortName: "collections",
    displayName: "Eclipse Collections"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
