local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "polarsys.polarsys.capella",
    shortName: "capella",
    displayName: "Eclipse Capella"
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  }
}
