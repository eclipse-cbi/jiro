local default = import '../../templates/config.libsonnet';

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
