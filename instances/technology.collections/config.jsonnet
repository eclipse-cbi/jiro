local default = import '../../templates/default.libsonnet';

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
