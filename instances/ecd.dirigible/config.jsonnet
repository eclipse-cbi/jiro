local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ecd.dirigible",
    shortName: "dirigible",
    displayName: "Eclipse Dirigible"
  },
  deployment: {
    host: "ci-staging.eclipse.org"
  }
}
