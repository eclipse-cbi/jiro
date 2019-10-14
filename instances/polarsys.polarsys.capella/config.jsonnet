local default = import '../../templates/default.libsonnet';

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
