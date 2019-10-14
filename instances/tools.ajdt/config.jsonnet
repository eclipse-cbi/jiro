local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "tools.ajdt",
    shortName: "ajdt",
    displayName: "Eclipse AJDT"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
